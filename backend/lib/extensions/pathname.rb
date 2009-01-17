require 'pathname'

class Pathname
  
  # Checks to see if the file is in the given directory.
  # Symlinks are resolved, so there is no tricking it with a symlink.
  # Unfortunately, to do this, the file system must be accessed and the files
  # and directories must exist.
  def in_directory?(dir_path)
    file_path = self.realpath
    dir_path = Pathname.new(dir_path).realpath
    raise RuntimeError, "Path is not a directory - #{dir_path.to_s}" unless dir_path.exist? && dir_path.directory?
    raise RuntimeError, "Path is not a file - #{file_path.to_s}" unless file_path.exist? && file_path.file?
    return file_path.to_s[0,dir_path.to_s.length] == dir_path.to_s
  end
  
end