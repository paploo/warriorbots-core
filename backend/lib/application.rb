require 'sim'
require 'application/command'

# The application object is the run-loop hub.  It manages the main runloop,
# including getting communications from the front-end and processing as
# necessary.
#
# The 
class Application
  
  @@instance = nil
  
  def self.instance
    return self.new
  end
  
  class << self
    alias_method :ruby_new, :new
  end
  
  def self.new(*args, &block)
    @@instance = self.ruby_new(*args, &block) if @@instance.nil?
    return @@instance
  end
  
  def initialize
    @arena = Sim::Arena.new
    @config = CONFIG
    @command_stack = ['DEBUGGING_INFO', 'EXIT'] # This is supposed to init to [] and get exit from a TCP/IP stack.
    Sim::Robot.start_server
  end
  
  attr_reader :arena, :config, :command_stack
  
  def run
    puts self.inspect
    loop do
      cmd = @command_stack.shift.to_s
      Application::Command.execute(cmd)
    end
  end
  
  def exit
    puts "[Exiting]"
    Kernel.exit(0)
  end
  
end