require 'rexml/document'
require 'rexml/parsers/sax2parser'
require 'rexml/sax2listener'
require 'pathname'

require 'configuration'

# TODO:
# The current parsing method is a 1970's C-style mess.  There is a better way.
# The difficulty is that the token stack needs to be in an expected state.
# If we underscore connect all the elements when a given process needs to be done,
# we can then call a method with that name.  For example, a component definition
# is only useful when the current stack is ['robot', 'components', component'].
# We could call robot_components_component, passing in any attributes and character
# data gathered during processing of the element, when the end_tag event is called.
# If the method exists, there is nothing to do, and we go on.

module Core
  class RobotConfiguration < Hash
    
    class ParseError < RuntimeError
    end
    
    include REXML::SAX2Listener
    
    @@element_names = ['robot', 'name', 'components', 'component', 'require', 'file']
    
    def initialize(file)
      puts file.inspect
      file_path = Pathname.new(file)
      io = File.new(file_path)
      @robot_definitions_seen = 0
      @parse_stack = []
      @parser = REXML::Parsers::SAX2Parser.new(io)
      @parser.listen(self)
      @parser.parse
      io.close
    end
    
    def start_element(uri, localname, qualified_name, attributes)
      # Print Diagnostic Line
      puts "START ELEMENT: #{uri}, #{localname}, #{qualified_name}, #{attributes.inspect}"
      
      # Add element to stack
      @parse_stack << localname
      
      # Do any special work up front.
      case localname
      when 'robot'
        raise "A config file cannot contain more than one robot." unless @robot_definitions_seen.zero?
      when 'component'
        if check_stack(['robot', 'components', 'component'])
          self['COMPONENTS'] ||= []
          self['COMPONENTS'] << attributes['class'] # This should really instantiate the class and add it to the list?
        else
          stack_error
        end
      else
        raise ParseError, "Unrecognized element name: #{localname}" unless @@element_names.include?(localname)
      end
    end
    
    def end_element(uri, localname, qualified_name)
      # Print Diagnostic Line
      puts "END ELEMENT: #{uri}, #{localname}, #{qualified_name.inspect}"
      
      # Pop the element from stack.
      stack_element = @parse_stack.pop
      raise ParseError, "End element encountered with no matching start element: got #{localname.inspect} but expected #{stack_element.inspect}" if localname != stack_element
      
      # Do any special work.
      case localname
      when 'robot'
        @robot_definitions_seen += 1
      else
        # Do nothing as element name validation was done up front.
      end
    end
    
    def characters(raw_text)
      text = raw_text.strip
      return if text.empty?
      puts "CHARACTERS: #{text}"
      
      case @parse_stack[-1]
      when 'robot'
        raise ParseError, "Unrecognized text in robot element: #{text}"
      when 'name'
        check_stack(['robot', 'name']) ? self['NAME'] = text : stack_error
      when 'file'
        if check_stack ['robot', 'require', 'file']
          self['REQUIRE_FILES'] ||= []
          self['REQUIRE_FILES'] << text
        else
          stack_error
        end
      else
        # Do nothing as element name validation was done up front.
      end
    end
    
    private
    
    def check_stack(*args)
      expected_stack = args.flatten
      return (expected_stack==@parse_stack) ? true : false
    end
    
    def stack_error(*args)
      expected_stack = args.flatten
      return unless expected_stack!=@parse_stack
      if expected_stack.empty?
        raise ParseError, "Unexpected illegal stack state #{@parse_stack.inspect}", caller
      else
        raise ParseError, "Expected parse stack to be #{expected_stack.inspect}, but it was #{@parse_stack.inspect}", caller
      end
    end
    
  end
end