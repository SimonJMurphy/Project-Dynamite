# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "kepler_processor/version"

Gem::Specification.new do |s|
  s.name        = "KeplerProcessor"
  s.version     = KeplerProcessor::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Simon Murphy", "Ben Langfeld"]
  s.email       = ["smurphy6@uclan.ac.uk", "ben@langfeld.me"]
  s.homepage    = "https://github.com/Smurfmeister/Project-Dynamite"
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = "kepler_processor"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "gsl"
  s.add_dependency "gnuplot"
  s.add_development_dependency "rspec"
end
