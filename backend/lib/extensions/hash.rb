class Hash
  
  def reverse_merge(h)
    h.merge(self)
  end
  
  def reverse_merge!(h)
    replace(reverse_merge(h))
  end
  
end