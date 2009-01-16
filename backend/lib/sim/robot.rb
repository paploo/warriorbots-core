require 'pathname'
require 'socket'
require 'thread'
require 'mutex_m'

require 'double_state_buffered_object'
require 'child_process'
require 'waiter'

module Sim
  class Robot < DoubleStateBufferedObject
    include Mutex_m
    
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
    
    def self.from_ident(ident)
      obj = ObjectSpace._id2ref(ident.to_i)
      return obj if obj.kind_of?(Robot)
      raise SecurityError, "Cannot find a Robot with ident=#{ident.inspect}"
    end
  
    def self.handle_connect(socket, handshake_data)
      LOG.debug "handle_connect(#{socket.inspect}, #{handshake_data.inspect})"
      robot = from_ident(handshake_data[:ident])
      robot.synchronize do
        robot.instance_variable_set(:@socket, socket)
        robot.instance_variable_get(:@bootstrap).done
      end
      return robot
    end
  
    def initialize(robot_dir)
      super()
      
      @robot_dir = Pathname.new(robot_dir).expand_path # The robot's source/resource directory.  NEVER RUN FILES IN IT!
      @ident = object_id.to_s # The guid of the robot.
      LOG.debug "New Robot Ident: #{ident}"
    
      @components = []
    
      @bootstrap = Waiter.new # A waiter that is used to wait until bootstrap is complete.
      @socket  = nil # The socket connection to the robot process.
      @thread = nil # The thread that the robot process is running in. (It does a wait and only exits if the script exits)
      @process = nil # The process object for the robot process in case one needs to poke it.
    end
    
    attr_reader :ident, :robot_dir, :components
    
    def bootstrapped?
      # When we have a bootstrap waiter, we haven't bootstrapped because it is
      # set to nil upon bootstrap completion.
      return !@bootstrap.nil?
    end
  
    def boot
      # Run the bootstrapper, in a thread, passing in the connection port, the robot ident, and script directory path.
      @thread = Thread.new do
        cmd = "#{CONFIG['RUBY_PATH']} #{CONFIG['BACKEND_ROOT']+'script'+'robot_bootstrap.rb'} --host localhost --port 4000 --ident #{ident} #{robot_dir}"
        LOG.debug cmd.inspect
        self.synchronize do
          @process = ChildProcess.new(cmd)
        end
        LOG.debug "Child Process For Robot #{ident} running on pid #{@process.pid}"
        @process.wait
        LOG.debug "Child Process For Robot #{ident} died."
      end
    
      # Wait for it to bootstrap, and then clear the waiter variable when done.
      @bootstrap.wait   
      @bootstrap = nil   
      LOG.debug( "Robot #{ident} bootstrapped." )
    end
  
  end
end