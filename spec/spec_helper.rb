require 'rubygems'
require 'bundler/setup'
require 'vcr'

require 'noids_client'

require 'webmock'
WebMock.enable!

VCR.configure do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock
  c.configure_rspec_metadata!
end

RSpec.configure do |config|
end
