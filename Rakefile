#!/usr/bin/env rake
#require "bundler/gem_tasks"
#Bundler.setup
load 'sassc.gemspec'
require 'rake/extensiontask'

Gem::PackageTask.new($gemspec) do |pkg|
end

Rake::ExtensionTask.new('libsass', $gemspec) do |ext|
  ext.lib_dir = 'lib/sassc'
end

task :run do
  require File.expand_path('../lib/sassc', __FILE__)
  ptr = SassC::Lib.sass_new_context()
  ctx = SassC::Lib::Context.new(ptr)
  ctx[:input_string] = SassC::Lib.to_char("hi { width: 30px; }")
  SassC::Lib.sass_compile(ctx)
  puts ctx[:output_string]
end