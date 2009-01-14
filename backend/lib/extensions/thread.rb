class Thread
  @@counter = 0
  
  # Setes the name of the thread to be the pid:thread_number.  The main thread
  # gets the number zero, all other threads get a number the first time :name is
  # called.
  def name
    if( @name.nil? )
      @name = (self==Thread.main) ? "#{Process::pid}:0" : "#{Process::pid}:#{'%02d' % (@@counter+=1)}"
    end
    return @name
  end
  
  def to_s
   return inspect
  end
  
  def inspect
    # We multiply the object_id by two, because that matches what ruby would otherwise return.
    # Seems object_id is always half the value of the actual pointer in ruby.
    return "<#{self.class.name}:0x#{(object_id*2).to_s(16)} #{name.inspect} #{status}>"
  end
end