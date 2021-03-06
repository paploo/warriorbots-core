require 'socket'
require 'optparse'
require 'logger'

require 'configuration'
require 'extensions'
require 'singleshire'
require 'warrior_code/robot'

module Core
  class Base
    include Singleshire
    
    # Initializes the core, but does not bootstrap it.
    def initialize
      # Define instance variables
      @log = nil
      @config = nil
      @robot = nil
      @socket = nil
      # Initialize those that should be done now.
      parse_arguments()
      setup_logger()
      # Call the block if necessary.
      yield(self) if block_given?
    end
    
    attr_reader :socket, :robot, :config
    
    # Bootstrap the script, getting it all up and running.
    def bootstrap
      establish_connection()
      load_robot()
      yield(self) if block_given?
    end
    
    # Start the primary event loop
    def run
      @socket.write_object({:foo => Time.now})
      sleep(2)
      LOG.info "[EXIT]"
    end
    
    private
    
    def parse_arguments
      # Create the configuration and its default values
      @config = Configuration.new do |conf|
        conf['CONNECTION_HOST'] = 'localhost'
        conf['CONNECTION_PORT'] = 4000
        
        conf['IDENT'] = nil
        conf['ROBOT_DIR'] = nil
      end
      
      # Define the kernel constant CONFIG that leads directly to the configuration
      Kernel.const_set('CONFIG', @config)
      
      # Parse the options
      ARGV.options do |opts|
        opts.banner = "Usage: ruby #{$0} [opts]"
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
    end
    
    # Setup the logger
    def setup_logger
      @log = Logger.new(STDOUT)
      @log.formatter = lambda do |level,time,program_name,msg|
        "[#{Thread.current.name.rjust(8)}][#{level.rjust(5)}] #{msg}\n"
      end
      
      Kernel.const_set('LOG', @log)
    end
    
    # Establishes a connection with the server and stores it where it can
    # be accessed.
    def establish_connection
      LOG.debug self.inspect
      LOG.debug "establish_connection:"
      LOG.debug([@config['CONNECTION_HOST'], @config['CONNECTION_PORT']].inspect)
      @socket = TCPSocket.new(@config['CONNECTION_HOST'], @config['CONNECTION_PORT']) # The port should be an arg.
      handshake_data_hash = {:ident => @config['IDENT'], :pid => Process.pid}
      @socket.write_object(handshake_data_hash)
    end
    
    # Load the robot
    def load_robot
      @robot = Robot.new(CONFIG['ROBOT_DIR'])
    end
    
  end
end