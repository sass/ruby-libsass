require 'mkmf'
require 'fileutils'
# .. more stuff
#$LIBPATH.push(Config::CONFIG['libdir'])
$CFLAGS << " #{ENV["CFLAGS"]}"
$LIBS << " #{ENV["LIBS"]}"

if Dir[File.expand_path('ext/libsass/*', __FILE__)].empty? 
  Dir.chdir(File.expand_path('.', __FILE__)) do
    xsystem('git submodule init')
    xsystem('git submodule update')
  end
end

Dir.chdir(File.expand_path('ext/libsass', __FILE__)) do
  create_makefile("libsass")  
end