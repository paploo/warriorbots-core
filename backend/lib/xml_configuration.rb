require 'rexml/document'
require 'rexml/parsers/sax2parser'
require 'rexml/sax2listener'

require 'configuration'

# A subclass of Configuration that parses an XML file.  This class is usually
# subclassed, overriding the process_element method for custom behavior, however
# it can be used as is.
#
# The parsing method used is not fully generic and is optimized for certain kinds
# of structures.  Here are some of the possible gotchas that can be encountered:
#  * This parser ignores any document level data (that is data outside
# of a tag).
#  * All character and cdata in an element is concatinated.
#  * Character/cdata, after concatination, has String#strip called on it.
#  * Entity references are not resolved, including character encodings like &amp;
class XMLConfiguration < Configuration
  include REXML::SAX2Listener
  
  class ParseError < RuntimeError; end
  
  def initialize(string)
    @stack = []
    
    @parser = REXML::Parsers::SAX2Parser.new(string)
    @parser.listen(self)
    @parser.parse
    
    yield(self) if block_given?
  end
  
  def start_element(uri, localname, qualified_name, attributes)
    @stack << {:element => localname, :attributes => attributes, :characters => ''}
  end
  
  def end_element(uri, localname, qualified_name)
    data = @stack.pop
    data[:context] = @stack.collect {|d| d[:element]}
    data[:characters] = (data[:characters]&&data[:characters].strip)
    process_element( data[:element], data[:context], data[:attributes], data[:characters] )
  end
  
  def characters(raw_text)
    @stack.last[:characters] << raw_text unless @stack.empty?
  end
  
  def cdata(raw_data)
    @stack.last[:characters] << raw_data unless @stack.empty?
  end
  
  # This is a default implementation that sets builds out the values in the hash.
  # This method should be overriden by sublcasses to do something more useful.
  def process_element(element, context, attributes, characters)
    data = {:element => element, :context => context, :attributes => attributes, :characters => characters}
    key = data[:context] && (data[:context] << data[:element]).compact.join(':')
    self[key] ||= []
    self[key] << data
  end
  
  # A helper method that builds a hash key out of the context by joining together
  # the context and the element.
  #
  # For example, if the element is 'file' and the context is ['dirs','lib']
  # then the key would be 'dirs:lib:file'.  (The join value, ':', can be
  # changed via the :join_string option.
  def build_key(element, context, opts={})
    opts.reverse_merge!({:join_string => ':'})
    return (context << element).join(opts[:join_string])
  end
  
end