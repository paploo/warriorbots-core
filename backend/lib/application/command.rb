class Application
  class Command
    
    def self.execute(cmd)
      cmd, *args = cmd.strip.split(/\s+/)
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