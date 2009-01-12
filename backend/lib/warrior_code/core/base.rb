require 'socket'
require 'optparse'

require 'configuration'
require 'extensions'

module WarriorCode
  module Core
    class Base
      @@instance = nil
      
      # Return the existing instance, or nil if there is not one yet.
      def self.instance
        return @@instance
      end
      
      class << self
        alias_method :new_ruby, :new
      end
      
      # New has been redefined to make sure only one instance of the base ever
      # exists.
      def self.new(*args, &block)
        @@instance = self.new_ruby(*args, &block) if @@instance.nil?
        return @@instance
      end
      
      # Initializes the core, but does not bootstrap it.
      def initialize
        parse_arguments()
        @robot = nil
        @socket = nil
        yield self if block_given?
      end
      
      attr_reader :socket, :robot, :config
      
      # Bootstrap the script, getting it all up and running.
      def bootstrap
        establish_connection()
        build_proxy_objects()
        security_clamp_down()
        load_robot()
        yield self if block_given?
      end
      
      private
      
      def parse_arguments
        # Create the configuration and its default values
        @config = Configuration.new do |conf|
          conf['CONNECTION_ADDRESS'] = 'localhost'
          conf['CONNECTION_PORT'] = 4000
          
          conf['IDENT'] = nil
          conf['ROBOT_DIR'] = nil
        end
        
        # Define the kernel constant CONFIG that leads directly to the configuration
        Kernel.const_set('CONFIG', @config)
        
        # Parse the options
        ARGV.options do |opts|
          opts.banner = "Usage: ruby robot_bootstrap.rb [opts]"
          opts.separator ""
          opts.on('-h', '--host=h', String, 'Sets the host to establish a connection with.') {|v| @config['CONNECTION_ADDRESS'] = v}
          opts.separator ""
          opts.on('-p', '--port=p', Integer, 'Sets the port to establish a connection with.') {|v| @config['CONNECTION_PORT'] = v}
          opts.separator ""
          opts.on('-i', '--ident=i', String, 'Sets the unique robot identifier.') {|v| @config['IDENT'] = v}
          opts.separator ""
          opts.on('--help', "Show this help message.") {puts opts; exit(0)}
          opts.parse!
        end
        
        # Get the script directory path off the end.
        raise ArgumentError, "No robot script path given" if ARGV.length.zero?
        @config['ROBOT_DIR'] = Pathname.new(ARGV.pop).expand_path
        
        puts '----- CONFIGURATION -----'
        puts @config.inspect
        puts '-------------------------'
      end
      
      # Establishes a connection with the server and stores it where it can
      # be accessed.
      def establish_connection
        @socket = TCPSocket.new('localhost', 4000) # The port should be an arg.
        handshake_data_hash = {:ident => ARGV[0].to_i, :pid => Process.pid}
        @socket.write_object(handshake_data_hash)
      end
      
      # Clamps down the security so that code loaded by the robot can't do
      # malicious things.  This keeps trojan robots out of the picture.
      def security_clamp_down
        $SAFE = 3
      end
      
      # Build the proxy objects, which are subclasses of Component.
      def build_proxy_objects
        
      end
      
      # Load the robot
      def load_robot
        @robot = Robot.new(filepath)
      end
      
    end
  end
end