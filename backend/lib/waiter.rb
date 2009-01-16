require 'thread'

# Waiters are a convenient tool for when you want to block a thread until another
# thread is ready for it to continue:
#
# w = Waiter.new
#
# Thread.new do
#   # Do some stuff
#   # Let the main thread continue
#   w.done
#   # Do more stuff, possibly for a while.
# end
#
# # wait for it to get done.
# w.wait
# # Do stuff
#
# It is marginally different than Thread's join method, in that join only works
# when a thread has exited, but sometimes it is necessary to pause a thread's
# execution until another thread reaches a certain intermmediate point.  (This
# can happen in communications situations, or when managing multiple processes.)
class Waiter
  
  # Creates a new waiter.
  def initialize
    @lock_thread = new_lock_thread()
    @mutex = Mutex.new
  end
  
  # Signals that any threads waiting on this waiter may continue.
  def done
    @mutex.synchronize do
      @lock_thread.kill
      @lock_thread = new_lock_thread()
    end
  end
  
  # Signals that the current thread should wait on this waiter.
  def wait
    lock_thread = nil
    @mutex.synchronize do
      lock_thread = @lock_thread
    end
    lock_thread.join
  end
  
  private
  
  def new_lock_thread
    # Sleep forever so it doesn't eat CPU.  A call to :kill gracefully kills
    # it even if it was asleep.
    return Thread.new { sleep() }
  end
  
end


# Test code:
if $0 == __FILE__

w = Waiter.new

Thread.new do
  puts '[sleep]'
  sleep(3)
  puts '[signal done]'
  w.done
  puts '[done]'
end

Thread.new do
  puts '(wait beta)'
  w.wait
  puts '(wait alpha beta)'
end

puts '(wait alpha)'
w.wait
puts '(wait alpha done)'
  

end #if $0 == __FILE__