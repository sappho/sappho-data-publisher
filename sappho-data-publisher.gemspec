# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "sappho-data-publisher/version"

# See http://docs.rubygems.org/read/chapter/20#page85 for info on writing gemspecs

Gem::Specification.new do |s|
  s.name        = Sappho::Data::Publisher::NAME
  s.version     = Sappho::Data::Publisher::VERSION
  s.authors     = Sappho::Data::Publisher::AUTHORS
  s.email       = Sappho::Data::Publisher::EMAILS
  s.homepage    = Sappho::Data::Publisher::HOMEPAGE
  s.summary     = Sappho::Data::Publisher::SUMMARY
  s.description = Sappho::Data::Publisher::DESCRIPTION

  s.rubyforge_project = Sappho::Data::Publisher::NAME

  s.files         = Dir['bin/*'] + Dir['lib/**/*']
  s.test_files    = Dir['test/**/*']
  s.executables   = Dir['bin/*'].map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
  s.add_development_dependency 'rake', '>= 0.9.2.2'
  s.add_dependency 'liquid', '>= 2.3.0'

end
