require 'pathname'

# Setup the special load path first
dir_path = File.dirname(__FILE__)
$LOAD_PATH << Pathname.new(dir_path).expand_path + 'lib'

# Load up the configuration class
require 'configuration'

# Do the main configuration
CONFIG = Configuration.init do |conf|
  # What is the path to the ruby executable used to boot robots?
  conf['RUBY_PATH'] = Pathname.new('/usr/local/bin/ruby')
  
  # Initialize the backend root variable.
  conf['BACKEND_ROOT'] = Pathname.new(dir_path).expand_path
  
  # Turn on abort_on_exception so that we can get errors from crashed threads.
  Thread.abort_on_exception = true
end

# Make the logger and configure it.
require 'logger'
LOG = Logger.new(STDOUT)
LOG.formatter = lambda do |level,time,program_name,msg|
  "[#{Thread.current.name.rjust(8)}][#{level.rjust(5)}] #{msg}\n"
end

# Load our custom thread extensions
require 'extensions/thread'

# Init the application object
require 'application'
APP = Application.init

# Configure any signal traps and exit loops
Signal.trap('SIGINT') {APP.exit}
Signal.trap('SIGQUIT') {APP.exit}
Signal.trap('SIGTERM') {APP.exit}

# Run
APP.run