require 'double_state_buffered_object'

module Sim
  class Component < DoubleStateBufferedObject
    
    # ==================== INHERITANCE / BUILDING ====================
    
    @@subclass_map = {}
    
    # Get a copy of the subclass map (for the curious?).
    def self.subclass_map
      return @@subclass_map.dup
    end
    
    # Makes a new Component instance of the given name for the given owning
    # robot.
    def self.new_for_name(name, robot)
      klass = @@subclass_map[name.to_s]
      raise ArgumentError, "Cannot turn argument into a Component class - #{type_name.inspect}" if klass.nil?
      raise TypeError, "Argument is not a class - #{klass.inspect}" unless klass.kind_of?(Class)
      raise TypeError, "Given class is not a Component - #{klass.inspect}" unless klass < Component
      return klass.new(owner_robot)
    end
    
    # Called whe na subclass is defined.  In order to make a class based on a
    # name, both in the backen application and the robot processes, we need to
    # be able to find the correct module without the top.
    def self.inherited(klass)
      key = klass.name.split('::').last
      @@sublcass_map[key] = klass
    end
    
    # Initialize the component as part of the given robot.
    def initialize(robot)
      @robot = robot
    end
    
    # ==================== CALLBACKS ====================
    
    # Defines callback methods on the class.  A callback method is not, itself
    # defined on the class.  Instead, a callback block is registered for
    # a callback on a method, and the callback is fired with the module
    # instance as the sole argument.
    def self.has_callbacks(*callbacks)
      @callbacks ||= []
      @callbacks |= callbacks.collect {|cb| cb.to_sym}
    end
    alias_method :has_callback, :has_callbacks
    
    # Returns a list of all the callbacks for this class.
    def self.callbacks
      callbacks = @callbacks || []
      callbacks |= superclass.callbacks if superclass.respond_to?(:callbacks)
      return callbacks
    end
    
    # Returns a list of all the callbacks for this instance.
    def callbacks
      return self.callbacks
    end
    
    # Fire the given callback.  This is actually more work than one might think,
    # because it has to proxy the call to the robot.
    def fire_callback(callback)
      # TODO: Implement fire_callback
    end
    
    # Fire all callbacks.  This is utilized when running a 'tick' on a robot.
    def fire_all_callbacks
      callbacks.each {|callback| fire_callback(callback)}
    end
    
    # ==================== APIs ====================
    
  end
end