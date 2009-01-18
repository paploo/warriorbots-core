require 'xml_configuration'
require 'pathname'

# Configuration sublcass that can read the robot configuration file.  Used by
# both the server and robot processes.
module Core
  class RobotConfiguration < XMLConfiguration
    
    def initialize(file_path)
      pn = Pathname.new(file_path).expand_path
      super(pn.read)
    end
    
    private
    
    def process_element(element, context, attributes, characters)
      method = ('process_' + build_key(element, context, :join_string => '_')).to_sym
      self.send(method, attributes, characters) if self.private_methods.include?(method.to_s)
    end
    
    def process_robot(attributes, characters)
      @robot_count ||= 0
      @robot_count += 1
      raise RuntimeError, "Only one robot can be declared in a robot configuration file." if @robot_count > 1
    end
    
    def process_robot_name(attributes, characters)
      self['NAME'] = characters
    end
    
    def process_robot_components_component(attributes, characters)
      self['COMPONENT_CLASSES'] ||= []
      self['COMPONENT_CLASSES'] << attributes['class']
    end
    
    def process_robot_require_file(attributes, characters)
      self['REQUIRE_FILES'] ||= []
      self['REQUIRE_FILES'] << Pathname.new(characters)
    end
    
  end
end