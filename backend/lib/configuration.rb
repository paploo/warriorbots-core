require 'pathname'
require 'singleshire'

class Configuration < Hash
  include Singleshire
  
  def initialize
    # Don't even try to call super.  The block will be passed in and give an
    # error because the Hash version of init takes over.
    yield(self) if block_given?
  end
  
  # Alias the default get/set methods so that we can override them.
  alias_method :ruby_get, :[]
  alias_method :ruby_set, :[]=
  private :ruby_get, :ruby_set
  
  # Override the default get method so that we can stringify the key.
  def [](key)
   ruby_get(key&&key.to_s)
  end
  
  # Override the default get method so that we can stringify the key.
  def []=(key,value)
   ruby_set(key&&key.to_s, value)
  end
  
end