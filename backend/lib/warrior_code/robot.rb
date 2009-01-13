require 'warrior_code/component'
require 'warrior_code/core/robot_configuration'

# This is not namespaced for ease of use by new robot devs.
#
# A security note: Since IO can be done on paths with untainted strings, it is
# important that we taint all the configuration file information as possible.
#
# !!! One possible security breech is a trojan with a require path.  It goes
# something like this:
#  1. In the config file, define the last require path to, say, an important file in the home directory.
#  2. In another required file, gain access to the untainted path, and run a destructive IO command on it.
# There is a way to allow requires but with some safety.  The application can not allow the requiring of
# files that are not in the robot's load directory (this can be accomplished by expanding the path and
# verifying that the file is within said directory and exists), and then taint the string when done.
# This, however, does not allow the requiring of ruby libraries that ship with ruby, nor loading
# libraries in the application.  However, if we separate the loads out so that all non-user files
# are required first (and subject to the same scrutiny), then we can be sure to load "safe" files
# first and "dangerous" files later, making sure that by the time we get to a "dangerous" file
# the strings from the "safe" files are already tainted.
class Robot
  
  def initialize(robot_dir)
    puts "LOAD ROBOT: #{robot_dir.inspect}"
    @robot_dir = Pathname.new(robot_dir).expand_path
    @config = Core::RobotConfiguration.new(robot_dir+'config.xml')
    puts @config.inspect
  end
  
end