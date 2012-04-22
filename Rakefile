#!/usr/bin/env rake
#require "bundler/gem_tasks"
#Bundler.setup
load 'sassc.gemspec'
require 'rake/extensiontask'

Rake::ExtensionTask.new('libsass') do |ext|
  ext.lib_dir = 'lib/sassc'
  ext.gem_spec = $gemspec
end

task :run do
  require File.expand_path('../lib/sassc', __FILE__)
  ptr = SassC::Lib.sass_new_context()
  ctx = SassC::Lib::Context.new(ptr)
  ctx[:input_string] = SassC::Lib.to_char("hi { width: 30px; }")
  puts "!!!" + SassC::Lib.sass_compile(ctx.to_ptr).to_s
  #puts ctx[:output_string]
end