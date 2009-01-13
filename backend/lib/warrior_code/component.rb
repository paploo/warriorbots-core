require 'warrior_code/core/component'

# This is not namespaced for ease of use by new robot devs.
#
# This class is the developer facing Component class, and contains the
# developer facing APIs.  (The backend work is done in Core::Component)
class Component < Core::Component
  
  # Returns a list of callbacks as symbols.
  def self.callbacks()
  end
  
  # Registers the passed block to the callback of the given name.
  def self.register_callback(callback, &block)
  end
  
  # Deregisters the given callback.
  def self.deregister_callback(callback)
  end
  
end