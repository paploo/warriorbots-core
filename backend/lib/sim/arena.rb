require 'double_state_buffered_object'

module Sim
  class Arena < DoubleStateBufferedObject
  
    has_double_buffered_attributes :tick
  
    def initialize
      self.tick_current = 0
      @robots = []
    end
    
    attr_reader :robots
  
    def load_robot(robot_dir)
      @robots << Robot.new(robot_dir)
    end
  
    def load_robots(*args)
      args.each {|robot_dir| load_robot(robot_dir)}
    end
  
  end
end