require 'base64'

# This provides extensions to IO classes to read/write objects.  Encodeing works by:
# 1. Marshaling the object
# 2. Base64 encoding the Marshal dump
# 3. Stripping out whitespace.
#
# The reason for all this is that it is easy to do comm over a loop where you
# read a single line and then handle it.  Unfortunately Marshaling encodes
# line feeds into the middle of the encoding.  Base64 forces the marshalled
# string into an encoding where line feeds are encoded, however Base64 itself
# automatically inserts a line feed every 60 characters.  Base64 could care less
# about the presence of these line feeds when decoding (as it just strips the
# whitespace anyway), so we strip it off ourselves before sending it over the
# network.
class IO
  
  def read_object
    str = readline
    return  Marshal.load( Base64.decode64(str) )
  end
  
  def write_object(object)
    str = Base64.encode64( Marshal.dump(object) ).gsub(/\s+/,'')
    puts(str)
  end
  alias_method :puts_object, :write_object
  
end