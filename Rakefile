# See https://github.com/sappho/sappho-data-publisher/wiki for project documentation.
# This software is licensed under the GNU Affero General Public License, version 3.
# See http://www.gnu.org/licenses/agpl.html for full details of the license terms.
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
