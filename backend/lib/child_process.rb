#
# A library for managing child processes.
# Only compatible with UNIX based systems.
#
class ChildProcess
  
  @@child_processes = []
  
  # Create a child process either by running a shell command or by supplying a
  # block to run.
  #
  # When running a shell command that is going to exit on its own, it is often
  # best to call wait, which blocks execution until the command has exited.
  # The second argument to new, if 'true', will call wait for you.
  def initialize(command=nil, wait=false, &block)
    if block.nil? 
      @pid = fork { exec(command) }
    else
      @pid = fork &block
    end
    Process::detach(@pid)
    
    @status = nil
    
    wait() if wait
  end
  
  # Return the pid of the related process.
  attr_reader :pid
  
  # Gets the status of the pid by calling ps.  Returns the recieved values as a
  # Hash.  If the process has already completed, the hash contains the Proces::Status
  # object and any keys pre-filled that it can..
  # The optional argument supplies an array of fields to parse.  The default
  # fields work on OS X 10.5 and Ubuntu 7.  There are few instances where
  # changing them is useful.
  def status(fields=['pid','ppid','stat','xstat','%cpu','%mem','rss','etime','ruser','command'])
    return {'Process::Status' => @status, 'PID' => @status.pid, 'XSTAT' => @status.exitstatus} if @status
    
    result = `ps -p #{@pid} -o #{fields.join(',')}`
    lines = result.split("\n")
    if lines[1]
      header = lines[0].strip.split(/\s+/)
      values = lines[1].strip.split(/\s+/,header.length)
      return Hash[ *(header.zip(values).flatten) ]
    else
      return {}
    end
  end
  
  # Checks to see if hte process is still running.  It firsts looks to see if
  # the process is already known to be terminated.  After that, it confirms it
  # is running using ps.
  # Note that zombies are reported as not running.  (Zombies can hang around for
  # a wee bit before being reaped, unless one uses wait.)
  def running?
    return false if( @status )
    
    result = `ps -o pid,stat -p #{@pid} | grep #{@pid}`.chomp
    if( result && result.length > 0 )
      stat = result.strip.split(/\s+/)[1]
      if stat=~/Z/
        wait()
        return false
      else
        return true
      end
    else
      return false
    end
  end
  
  # Asks to quit the process by sending a signal to the process (default SIGTERM),
  # waits for it to exit, and then returns the cleanup information as an array.
  #
  # Note that if the child process is your own ruby script, you should call
  # something like:
  #     Signal.trap('SIGTERM') { exit(0) }
  # so that it quits cleanly. 
  def quit(signal='SIGTERM')
    kill(signal)
    @status = wait()
    return @status
  end
  
  # Send any signal to the process.  By default it sends a SIGTERM, just like
  # UNIX's kill command.  It does not wait for the process to run the signal,
  # therefore, if giving a signal that results in termination, it is better to
  # use :quit.
  def kill(signal='SIGTERM')
    return false if @status
    
    begin
      result = Process::kill(signal, @pid)
      return result
    rescue Errno::ESRCH => e
      return false
    end
  end
  alias_method :signal, :kill
  
  # Causes the current thread to block until the process has exited and its status
  # has been reaped.
  def wait()
    return @status if @status
    
    begin
      pid, @status = Process.wait2(@pid)
    rescue Exception => e
      pid, @status = [nil, nil]
    end
    
    return @status
  end
  
  # Output a human readable form.
  def to_s
    exited_s = @status.nil? ? 'false' : "true(#{@status.exitstatus})}"
    return "#<#{self.class.name}:0x#{object_id.to_s(16)} pid=#{@pid}, exited=#{exited_s}>"
  end
  
  # Output a human readable detailed form.
  def inspect
    return to_s
  end
  
end