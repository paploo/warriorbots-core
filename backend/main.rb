# Load up the configuration class
dir_path = File.dirname(__FILE__)
require File.join(dir_path, 'lib', 'configuration')

# Do the main configuration
CONFIG = Configuration.new() do |conf|
  # What is the path to the ruby executable used to boot robots?
  conf['RUBY_PATH'] = Pathname.new('/usr/local/bin/ruby')
  
  # Initialize the backend root variable.
  conf['BACKEND_ROOT'] = Pathname.new(dir_path).expand_path
  
  # Build the initial list of library search paths.
  conf['LIB_DIR'] = conf['BACKEND_ROOT'] + 'lib'
  
  # Turn on abort_on_exception so that we can get errors from crashed threads.
  Thread.abort_on_exception = true
end

# Make the logger and configure it.
require 'logger'
LOG = Logger.new(STDOUT)
LOG.formatter = lambda do |level,time,program_name,msg|
  "[#{Thread.current.name.rjust(8)}][#{level.rjust(5)}] #{msg}\n"
  #{}"[#{time.strftime('%Y-%m-%d %H:%M:%S')}][#{Process.pid.to_s.rjust(5)}][#{level.rjust(5)}] #{msg}\n"
end

# Define a load path that leads directly to the application's lib directory.
$LOAD_PATH << CONFIG['LIB_DIR'].expand_path.to_s

# Load our custom thread extensions
require 'extensions/thread'

# Init the application object
require 'application'
APP = Application.new

# Configure any signal traps and exit loops
Signal.trap('SIGINT') {APP.exit}
Signal.trap('SIGQUIT') {APP.exit}
Signal.trap('SIGTERM') {APP.exit}

# Run
APP.run