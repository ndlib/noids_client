require "bundler/gem_tasks"

desc "Test the current client against a NOIDs server (see https://github.com/ndlib/noids)"
task :test_client_against_server do
  require 'noids_client/integration_test'
  NoidsClient::IntegrationTest.run
end
