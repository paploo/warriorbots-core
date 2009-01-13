module Core
  class Component
    
    # Define all proxy I/O commands:
    # * API proxy methods
    # * Callbacks are handled via the Robot, which, as part of its main event loop, initiates callbacks in an orderly fashion.
    
    def call_api_instance_method(method, *args)
    end
    private :call_api_instance_method
    
  end
end