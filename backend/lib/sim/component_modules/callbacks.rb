raise RuntimeError, "This file is not used!  Please delete it!"

module Sim
  module ComponentModules
    module Callbacks
    
      def self.included(klass)
        klass.send(:extend, ClassMethods)
        klass.send(:include, InstanceMethods)
      end
    
      module ClassMethods
        
        # Defines callback methods on the class.  A callback method is not, itself
        # defined on the class.  Instead, a callback block is registered for
        # a callback on a method, and the callback is fired with the module
        # instance as the sole argument.
        def has_callbacks(*callbacks)
          @callbacks ||= []
          @callbacks |= callbacks.collect {|cb| cb.to_sym}
        end
        alias_method :has_callback, :has_callbacks
        
        #  Returns a list of all the callbacks for this class.
        def callbacks
          callbacks = @callbacks || []
          callbacks |= superclass.callbacks if superclass.respond_to?(:callbacks)
          return callbacks
        end
      end
    
      module InstanceMethods
        
        # We need two slightly different methods here.  One is for the sim/component,
        # in which a firing sends a message over the robot's connection to run
        # the callback on the appropriate component.  The other is the version
        # run on the WarriorCode::Component, which calls the correct callback
        # block.
        #
        # There are three solutions
        #  1. Maintain completely separate callback module files for the backend
        #     and the robots
        #  2. In self.included, look at the klass we are extending and decide
        #     if it is a front end or a backend and include different modules
        #     from the same file.
        #  3. Design a generic interface to a few root methods that can be
        #     appropriately implemented in each version.
        #  4. Make *all* methods be proxy methods, and have Proc objects be
        #     Marshaled in such a way where ones created in the robot process
        #     have a proxy version in the sim that forwards all calls to the
        #     robot process.
        
        def register_callback(callback, &block)
        end
        
        def unregister_callback(callback)
        end
        
        def fire_callback(callback)
        end
        
      end
      
    end
  end
end