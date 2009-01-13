# Find the lib directory and make a loadpath for it.
require 'pathname'
LIB_DIR =  Pathname.new(__FILE__).dirname + '..' + 'lib'
$LOAD_PATH << LIB_DIR.to_s

# Require what we need to get started
require 'warrior_code/core/base'

# Start the wrapped code
begin
  Core::Base.new
  Core::Base.instance.bootstrap
  Core::Base.instance.run
rescue SystemExit => e
  exit(e.status)
rescue Exception => e
  STDERR << e.to_full_s
  exit(1)
end