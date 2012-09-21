# See https://wiki.sappho.org.uk/display/DP/sappho-data-publisher for project documentation.
# This software is licensed under the GNU General Public License, version 3.
# See http://www.gnu.org/licenses/gpl.html for full details of the license terms.
# Copyright 2012 Andrew Heald.

require "bundler/gem_tasks"
require 'rake/testtask'

task :default => :test
task :install => :test
task :release => :test

Rake::TestTask.new(:test) do |t|
  t.libs << 'test/ruby'
  t.pattern = 'test/ruby/**/*_test.rb'
  t.verbose = true
end
