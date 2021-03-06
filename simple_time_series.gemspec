# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'simple_time_series/version'

Gem::Specification.new do |spec|
  spec.name          = "simple_time_series"
  spec.version       = SimpleTimeSeries::VERSION
  spec.authors       = ["James Lavin"]
  spec.email         = ["simple_time_series@futureresearch.com"]
  spec.summary       = %q{Packages a set of time series variables into an object for easy data access and manipulation}
  spec.description   = %q{Packages a set of time series variables into an object for easy data access and manipulation}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
