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
          handle_connect(socket, handshake_data)
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
        robot.send(:bootstrap, socket)
      end
      return robot
    end
    
    class << self
      private :handle_connect
    end
    
    
    # Load the robot.  This fills out most of the robot, but stops short of booting
    # the robot subprocess and building communications.
    def initialize(robot_dir)
      super()
      
      @robot_dir = Pathname.new(robot_dir).expand_path # The robot's source/resource directory.  NEVER RUN FILES IN IT!
      @config = RobotConfiguration.new(robot_dir + 'config.xml')
      
      @ident = object_id.to_s # The guid of the robot.
      LOG.debug "New Robot Ident: #{ident}"
    
      build_components()
    
      @bootstrap = Waiter.new # A waiter that is used to wait until bootstrap is complete.
      @socket  = nil # The socket connection to the robot process.
      @process_thread = nil # The thread that the robot process is running in. (It does a wait and only exits if the script exits)
      @process = nil # The process object for the robot process in case one needs to poke it.
    end
    
    attr_reader :ident, :robot_dir, :components
    
    # Returns true if the robot subprocess has been booted, but gives no indication
    # of the currnt status of the subprocess.
    def bootstrapped?
      # When we have a bootstrap waiter, we haven't bootstrapped because it is
      # set to nil upon bootstrap completion.
      return !@bootstrap.nil?
    end
  
    # Boots the robot
    def boot
      # Run the bootstrapper, in a thread, passing in the connection port, the robot ident, and script directory path.
      @process_thread = Thread.new do
        cmd = "#{CONFIG['RUBY_PATH']} #{CONFIG['BACKEND_ROOT']+'lib'+'warrior_code'+'core'+'bootstrap.rb'} --host localhost --port 4000 --ident #{ident} #{robot_dir}"
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
    
    private
    
    def bootstrap(socket)
      @socket = socket
      
      # Make the comm thread
      @comm_thread = Thread.new do
        command_obj = @socket.read_object
        dispatch_command( command_obj )
      end
      
      @bootstrap.done
    end
    
    def dispatch_command( command_obj )
      LOG.debug "COMMAND OBJ: #{command_obj.inspect}"
    end
    
    def build_components
      @config['COMPONENTS'].collect do |class_name|
        Component.new_for_class(class_name, self)
      end
    end
  
  end
end