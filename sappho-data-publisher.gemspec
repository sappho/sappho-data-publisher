# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "sappho-data-publisher/version"

Gem::Specification.new do |s|
  s.name        = "sappho-data-publisher"
  s.version     = Sappho::Data::Publisher::VERSION
  s.authors     = ["Andrew Heald"]
  s.email       = ["andrew@heald.co.uk"]
  s.homepage    = "https://github.com/sappho/sappho-data-publisher/wiki"
  s.summary     = "Publishes aggregated data to formatted pages on a wiki"
  s.description = "See the project home page for more information"

  s.rubyforge_project = "sappho-data-publisher"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
  s.add_development_dependency 'rake', '>= 0.9.2.2'
  s.add_dependency 'liquid', '>= 2.3.0'

end
