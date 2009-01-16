# My own singleton implementtion.  It is less strict than that given by
# the ruby framework, and gives better control over initialization during
# creation (takes arguments and a block and hands it to new), and when
# you get the instance, a block can be passed to do multiple operations
# on it.
module Singleshire
  
  # Define instance methods for "the instance".
  module InstanceMethods
    
    def clone
      return self.class.instance
    end
    
    def dup
      return self.class.instance
    end
  end
  
  module ClassMethods
    def init(*args, &block)
      if @singleshire_instance.nil?
        @singleshire_instance = new(*args, &block)
        return @singleshire_instance
      else
        raise ArgumentError, "The instance has already been initialized."
      end
    end
    
    def instance(&block)
      yield @singleshire_instance if block_given?
      return @singleshire_instance
    end
    
    def initialized?
      return !@singleshire_instance.nil?
    end
  end
  
  private
  
  def self.included(klass)
    klass.send(:include, InstanceMethods)
    class << klass
      private :new
      include ClassMethods
    end
  end
  
end