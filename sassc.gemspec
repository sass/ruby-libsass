# -*- encoding: utf-8 -*-
#require File.expand_path('../lib/sassc', __FILE__)

$gemspec = Gem::Specification.new do |gem|
  gem.name          = "sassc"
  gem.authors       = ["Hampton Catlin", "Aaron Leung"]
  gem.email         = ["hcatlin@gmail.com"]
  gem.description   = %q{A Ruby wrapper for the libsass project}
  gem.summary       = %q{libsass wrapper}
  gem.homepage      = "http://github.com/hcatlin/libsass"

  gem.files         = Dir["*", "ext/**/*", "lib/sassc.rb", "lib/sassc/*", "lib/sassc/**/*"]
  gem.executables   = []#gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  
  gem.platform = Gem::Platform::RUBY
  gem.extensions    = ["ext/libsass/extconf.rb"]
  gem.require_paths = ["lib", "exts"]
  gem.version       = "0.1"#SassC::VERSION
  
  gem.add_dependency('ffi')
  gem.add_dependency('rake-compiler')
end
