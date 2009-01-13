require 'pathname'

class Configuration < Hash
  
  @@instance = nil
  
  def self.instance
    return @@instance
  end
  
  class << self
   alias_method :ruby_new, :new
  end
  
  def self.new(*args, &block)
   @@instance = self.ruby_new(*args, &block) if @@instance.nil?
   return @@instance
  end
  
  def initialize()
    # Putting the super in causes some interesting issues:  multiple values for a block parameter (2 for 1) when accessing an element.
    # My guess is that it uses the block given when trying to access a key that doesn't exist.
    #super()
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