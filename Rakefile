require "bundler/gem_tasks"

desc "Test the current client against a NOIDs server (see https://github.com/ndlib/noids)"
task :test_client_against_server do
  puts "This test assumes a fresh restart of the in memory noids pool"
  asserter = ->(test, message) do
    if test # The test passed
      puts message
      return true
    else
      raise RuntimeError,  "FAILED EXPECTATION: #{message}"
    end
  end
  require 'noids_client'
  default_noids_url = "http://localhost:13001"
  noids_url = ENV.fetch("NOIDS_URL") do
    puts "Using default NOIDS_URL of #{default_noids_url}"
    default_noids_url
  end
  connection = NoidsClient::Connection.new(noids_url)
  asserter.call(connection.pool_list.empty?, "Expected connection.pool_list to be empty")
  new_pool = connection.new_pool("test", ".sddd")
  asserter.call(new_pool, "Expected to be able to create a pool")
  asserter.call(connection.pool_list.include?("test"), "Expected connection.pool_list to include test")
  pool = connection.get_pool("test")
  asserter.call(pool.name == "test", "Expected pool to be named 'test'")
  asserter.call(pool.ids_used == 0, "Expected pool to have no used IDs")
  ids = pool.mint(2)
  asserter.call(ids.size == 2, "Expected to mint 2 ids with `pool.mint(2)`")
  asserter.call(pool.close, "Expected close to be successful")
  asserter.call(pool.open, "Expected to be able to re-open the pool")
  asserter.call(pool.ids_used == 2, "Expected the previously minted ids to register as used")
end
