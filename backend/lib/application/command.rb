class Application
  class Command
    
    def self.execute(cmd)
      self.send(cmd.to_s.downcase.to_sym)
    end
    
    # Exit the backend; quit gracefully
    def self.exit
      Application.instance.exit
    end
    
    # Exit the backend; quit gracefully
    def self.quit
      self.exit
    end
    
    # Print whatever debugging information the developers feel like printing to
    # standard out.
    def self.debugging_info
      puts "========== DEBUGGING INFO =========="
      puts "===================================="
    end
    
  end
end