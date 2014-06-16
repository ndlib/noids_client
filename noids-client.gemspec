Gem::Specification.new do |spec|
  spec.name        = 'noids-client'
  spec.version     = '0.0.0'
  spec.summary     = 'Ruby client for a NOIDS server'
  spec.description = %q{Provides an idiomatic interface to the REST API of a noids server (see https://github.com/dbrower/noids)}
  spec.authors     = ['Don Brower']
  spec.email       = ['dbrower@nd.edu']
  spec.license     = 'APACHE2'

  spec.files       = `git ls-files`.split($/)

  spec.add_depencency = 'rest-client', '~> 1.6'
  spec.add_depencency = 'json', '~> 1.8'
  spec.require_paths = ['lib']
end

