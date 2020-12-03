# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'noids_client/version'

Gem::Specification.new do |spec|
  spec.name        = 'noids_client'
  spec.version     = NoidsClient::VERSION
  spec.summary     = 'Ruby client for a NOIDS server'
  spec.description = %q{Provides an idiomatic interface to the REST API of a noids server (see https://github.com/dbrower/noids)}
  spec.authors     = ['Don Brower', "Jeremy Friesen"]
  spec.email       = ['dbrower@nd.edu', "jeremy.n.friesen@gmail.com"]
  spec.license     = 'APACHE2'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'rest-client', '~> 2.0'
  spec.add_dependency 'json', '~> 1.8'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'vcr', '~> 2.8'
  spec.add_development_dependency 'webmock', '~> 3.0'
  spec.add_development_dependency 'byebug'
end
