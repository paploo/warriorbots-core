require 'rexml/document'
require 'rexml/parsers/sax2parser'
require 'rexml/sax2listener'
require 'pathname'

require 'configuration'

# TODO:
# The current text and attributes gathering should utilize a stack, so that 
# attributes on nested components can be retrieved at the correct time.
# Really, I need a stack of hashes with this kind of data!

module Core
  class RobotConfiguration < Hash
    
    class ParseError < RuntimeError
    end
    
    include REXML::SAX2Listener
    
    @@element_names = ['robot', 'name', 'components', 'component', 'require', 'file']
    
    def initialize(file)
      LOG.debug file.inspect
      file_path = Pathname.new(file)
      io = File.new(file_path)
      @current_data = {:robot_definitions_seen => 0, :parse_stack => []}
      @parser = REXML::Parsers::SAX2Parser.new(io)
      @parser.listen(self)
      @parser.parse
      io.close
    end
    
    def start_element(uri, localname, qualified_name, attributes)
      # Raise an error if the element is unrecognized.
      raise ParseError, "Unrecognized element name: #{localname}" unless @@element_names.include?(localname)
      
      # Special check
      raise "The configuration file may only define a single robot." if localname=='robot' && @current_data[:robot_definitions_seen]!=0
      
      # Add element to stack and take any necessary notes
      @current_data[:parse_stack] << localname
      @current_data[:attributes] = attributes
      @current_data[:text] = ''
    end
    
    def end_element(uri, localname, qualified_name)
      
      # Error if the tag is unexpected
      stack_element = @current_data[:parse_stack][-1]
      raise ParseError, "End element encountered with no matching start element: got #{localname.inspect} but expected #{stack_element.inspect}" if localname != stack_element
      
      # Build the method and call it, if available
      method = ("process_" + @current_data[:parse_stack].join('_').underscore).to_sym
      STDOUT << "send(#{method.inspect}) with current data #{@current_data.inspect}\n\n"
      self.send(method) if (methods|private_methods).include?(method.to_s)
      
      # Pop off the top element as we are done with it now.
      @current_data[:parse_stack].pop
      @current_data[:attributes] = {}
      @current_data[:text] = ''
    end
    
    def characters(raw_text)
      @current_data[:text] += raw_text.strip
    end
    
    private
    
    def process_robot
      @current_data[:robot_definitions_seen] += 1
    end
    
    def process_robot_name
      self['NAME'] = @current_data[:text]
    end
    
  end
end