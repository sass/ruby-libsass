#!/usr/bin/env rake
#require "bundler/gem_tasks"
#Bundler.setup
load 'sassc.gemspec'
require 'rake/extensiontask'

Gem::PackageTask.new($gemspec) do |pkg|
end

Rake::ExtensionTask.new('libsass', $gemspec)

task :run => :compile do
  require File.expand_path('../lib/sassc', __FILE__)
  engine = SassC::Engine.new(".hi { width: 30px; }")
  puts engine.render.inspect
end