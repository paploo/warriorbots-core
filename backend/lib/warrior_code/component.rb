# This is not namespaced for ease of use by new robot devs.
class Component
  
  # Need code for managing componet communications:
    # Send messages to the server.
    # Get the response for the send (which I expect we'll just wait on I/O for the response?
    # Recieve callback requests.
  
  # In 'production', the component definitions don't change.  Therefore it is
  # fastest for robot booting to have class files for each component defined in
  # the warrior_code framework.  The method stubs all need to call the same
  # private method that sends the API call via proxy.
  
end