require "bundler/gem_tasks"
require 'rake/testtask'

task :default => :test
task :install => :test
task :release => :test

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end
