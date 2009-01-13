class Application
  class Command
    
    def self.execute(cmd)
      cmd, *args = cmd.strip.split(/\s+/) # This needs to be replaced with XML commands when the spec is solidified
      method = (cmd.nil?||cmd.empty?) ? nil : cmd.downcase.to_sym
      if( method && self.respond_to?(cmd) )
        begin
          self.send(method, *args)
        rescue ArgumentError => e
          STDERR.puts "#{e.class.name}: #{e.message}"
        end
      else
        STDERR.puts "Unknown command #{cmd.inspect}"
      end
    end
    
    def self.help
      puts (self.methods - Object.methods).sort.inspect
    end
    
    # Exit the backend; quit gracefully
    def self.exit(status=0)
      Application.instance.exit(status)
    end
    
    # Exit the backend; quit gracefully
    def self.quit
      self.exit
    end
    
    # Print whatever debugging information the developers feel like printing to
    # standard out.
    def self.debugging_info
      puts "========== DEBUGGING INFO =========="
      puts "Arena:"
      puts "#{APP.arena.inspect}"
      puts "===================================="
    end
    
    # The default for the argument should be removed when things are working better.
    def self.load_robot(path="/Users/paploo/Projects/SVN_Crudephysics/trunk/backend/test/test_robot")
      pn = Pathname.new(path).expand_path
      puts "Loading with path: #{pn.to_s}"
      APP.arena.load_robot(path)
    end
    
    def self.boot_robot(ident)
      robot = Sim::Robot.from_ident(ident)
      robot.boot
    end
    
  end
end