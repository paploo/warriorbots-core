class Exception
  def to_full_s
    "#{self.class.name}: #{self.message}\n  " + backtrace.join("\n  ")
  end
end