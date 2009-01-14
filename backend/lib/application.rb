require 'extensions'
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
    Sim::Robot.start_server
  end
  
  attr_reader :arena, :config
  
  def run
    t = Thread.new do
      LOG.info "Running with ruby #{RUBY_VERSION} p#{RUBY_PATCHLEVEL}"
      loop do
        STDOUT << '>> '
        STDOUT.flush
        cmd = STDIN.gets.chomp # This would normally be taking input from TCP/IP
        begin
          Application::Command.execute(cmd)
        rescue SystemExit => se
          raise se
        rescue Exception => e
          STDERR.puts e.to_full_s
        end
      end
    end
    t.join
  end
  
  def exit(status=0)
    status = status.to_i
    LOG.info "[Exiting#{'(' + status.to_s + ')' unless status.zero?}]"
    Kernel.exit(status)
  end
  
end