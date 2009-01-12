require 'pathname'
require 'socket'

require 'double_state_buffered_object'
require 'child_process'

module Sim
  class Robot < DoubleStateBufferedObject
    @@server = nil
    @@port = 4000
  
    def self.start_server
      @@server = TCPServer.new('localhost', @@port)
    
      Thread.new(@@server) do |server|
        loop do
          socket = server.accept
          handshake_data = socket.read_object
          self.handle_connect(socket, handshake_data)
        end
      end
    end
  
    def self.handle_connect(socket, handshake_data)
      robot = robot_for_ident(handshake_data[:ident])
      robot.instance_variable_set(:@socket, socket)
      robot.instance_variable_set(:@bootstrapped, true)
      return robot
    end
  
    def initialize(script_dir)
      @script_dir = Pathname.new(script_dir) # The robot's source/resource directory.
      @ident = object_id # The id of the robot.
    
      @components = []
    
      @bootstrapped = false # Set to true once the script is up and running.
      @socket  = nil # The socket connection to the robot process.
      @thread = nil # The thread that the robot process is running in. (It does a wait and only exits if the script exits)
      @process = nil # The process object for the robot process in case one needs to poke it.
    end
  
    def boot
      # Run the bootstrapper, in a thread, passing in the connection port, the robot ident, and script directory path.
      @thread = Thread.new
    
      # Wait for it to bootstrap
      start_wait = Time.now
      while( !@bootstrapped )
        sleep(0.1)
        delta_t = Time.now - start_wait
        raise RuntimeError, "Bootstrapping seems to have failed; waited 60 seconds." if delta_t > 60.0
      end
    end
  
  end
end