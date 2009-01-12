# has_double_buffered_attributes(*args)
# Takes a list of symbols or strings that are double buffered attributes and generates accessors for them as so:
#  name :: returns the current value
#  name= :: sets the buffered value
#  name? (returns the boolified current value)
#  name_values (returns an array of [current, buffered])
#  name_values= (takes an array of [current, buffered] to overwrite both.)
#  name_current
#  name_current=
#  name_buffered
#  name_buffered=
#  name! (merges the buffered data into the current data)
#
# The attribute lists are handled through instance variables defined on the *Class* subclass,
# NOT on an instance.  This is better than the normal class variables because each Class instance (subclass)
# gets its own instance, insteaad of sharing one instance across all.

# has_mergable_attributes(*args)
# Used to maintain a list of mergable attributes (ones that respond to :merge_buffers).
# This is more efficient than self-discovery, which is needed for this application.

# merge_buffers
# The merge_buffered method first iterates through all the double buffered attributes
# and merges them, before calling :merge_buffers on other objects.  (Some classes,
# such as Array and Hash, have merge_buffers implemented on them as well, so that
# collections of objects can be merged using this infrastructure.)

class DoubleStateBufferedObject
  
  def self.has_double_buffered_attributes(*args)
    args.flatten.each do |name|
      # First build the base methods
      class_eval "def #{name}_current; return @#{name}_current; end"
      class_eval "def #{name}_current=(o); @#{name}_current=o; end"
      class_eval "def #{name}_buffered; return @#{name}_buffered; end"
      class_eval "def #{name}_buffered=(o); @#{name}_buffered=o; end"
      
      # Now build the normally used ones
      class_eval "def #{name}; return #{name}_current; end"
      class_eval "def #{name}=(o); self.#{name}_buffered=o; end"
      class_eval "def #{name}?; return (#{name} ? true : false); end"
      class_eval "def #{name}_values; return [#{name}_current, #{name}_buffered]; end"
      class_eval "def #{name}_values=(*args); cur,nex=args.flatten; self.#{name}_current=cur; self.#{name}_buffered=nex; end"
      
      # And now we need the merge method
      class_eval "def #{name}!; self.#{name}_current = #{name}_buffered; end;"
      
      # Add the name to a double buffered attribute list
      class_eval "@double_buffered_attributes ||= []; @double_buffered_attributes << name.to_sym"
      class_eval "@double_buffered_attribute_merge_method_symbols ||= []; @double_buffered_attribute_merge_method_symbols << (name.to_s + '!').to_sym"
    end
  end
  
  def self.has_mergable_attributes(*args)
    args.flatten.each do |name|
      class_eval "@mergable_attributes ||= []; @mergable_attributes << name.to_sym"
      class_eval "@mergable_attributes_ivar_symbols ||= []; @mergable_attributes_ivar_symbols << ('@' + name.to_s).to_sym"
    end
  end
  
  def self.double_buffered_attributes
    return gather_list(:double_buffered_attributes)
  end
  
  def self.mergable_attributes
    return gather_list(:mergable_attributes)
  end
  
  # Using a dynamic method like this instead of building a bunch of static methods
  # to access these lists is only about 1.5x slower.  But who cares when the avg
  # execution speed is measured in tens of *micro* seconds.
  def self.gather_list(accessor_sym)
    ivar_sym = ("@" + accessor_sym.to_s).to_sym
    self_list = instance_variable_get(ivar_sym) || []
    if( superclass.respond_to?(accessor_sym) )
      return superclass.send(accessor_sym) | self_list
    else
      return self_list.dup
    end
  end
  
  class << self
    alias_method :has_double_buffered_attribute, :has_double_buffered_attributes
    alias_method :has_mergable_attribute, :has_mergable_attributes
    private :gather_list
  end
  
  def double_buffered_attributes
    return self.class.double_buffered_attributes
  end
  
  def mergable_attributes
    return self.class.mergable_attributes
  end
  
  def gather_list(accessor_sym)
    return self.class.send(:gather_list, accessor_sym)
  end
  
  
  def merge_buffers
    gather_list(:double_buffered_attribute_merge_method_symbols).each {|merge_method| self.send(merge_method) }
    gather_list(:mergable_attributes_ivar_symbols).each {|ivar| instance_variable_get(ivar).merge_buffers}
  end
  
end


# Define a buffer merge for Array
class Array
  
  def merge_buffers
    self.each {|obj| obj.merge_buffers}
  end
  
end

# Define a buffer merge for Hash
class Hash
  
  def merge_buffers
    self.values.each {|obj| obj.merge_buffers}
  end
  
end