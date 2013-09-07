# -*- encoding: utf-8 -*-
#require File.expand_path('../lib/sassc', __FILE__)

$gemspec = Gem::Specification.new do |gem|
  gem.name          = "sassc"
  gem.authors       = ["Hampton Catlin", "Aaron Leung"]
  gem.email         = ["hcatlin@gmail.com"]
  gem.description   = %q{A Ruby wrapper for the libsass project}
  gem.summary       = %q{libsass wrapper}
  gem.homepage      = "http://github.com/hcatlin/sassruby"

  gem.files         = `git ls-files`.split("\n")
  gem.executables   = []#gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  
  gem.platform = Gem::Platform::RUBY
  gem.extensions    = ["ext/libsass/extconf.rb"]
  gem.require_paths = ["lib", "ext"]
  gem.version       = "0.3"#SassC::VERSION
  
  gem.add_dependency('ffi')
  gem.add_dependency('rake-compiler')

  gem.add_development_dependency("guard")
  gem.add_development_dependency("guard-test")

end