require 'noids_client'

module NoidsClient
  # A helper class that allows for downstream implementers of the noids_clients
  # gem to run against a "live" noids server
  #
  # @example
  #   require 'noids_client/integration_test'
  #   NoidsClient::IntegrationTest.run
  #
  # @see #initialize for .run parameters
  class IntegrationTest
    class AssertionFailedError < RuntimeError
    end

    def self.run(start_fresh_noids_test_server: false, **args)
      start_fresh_noids_test_server! if start_fresh_noids_test_server
      new(**args).run
    end

    def self.start_fresh_noids_test_server!
      raise NotImplemented
    end

    # @params noids_url [String]
    # @params logger [#info, #fatal]
    # @params connection_class [#new] a connection class that implements the
    #           NoidsClient::Connection object interface
    def initialize(noids_url: default_noids_url, logger: default_logger, connection_class: default_connection_class)
      @logger = logger
      @noids_url = noids_url
      @connection_class = connection_class
      connect!
    end
    attr_reader :noids_url, :logger, :connection, :connection_class

    private

    def connect!
      logger.debug "Using #{noids_url} to connect via #{connection_class}"
      @connection = connection_class.new(noids_url)
    end

    def default_noids_url
      default_noids_url = "http://localhost:13001"
      ENV.fetch("NOIDS_URL") do
        default_noids_url
      end
    end

    def default_logger
      require 'logger'
      Logger.new(STDOUT)
    end

    def default_connection_class
      require 'noids_client'
      NoidsClient::Connection
    end

    public

    def run
      assert(connection.pool_list.empty?, "Expected connection.pool_list to be empty")
      new_pool = connection.new_pool("test", ".sddd")
      assert(new_pool, "Expected to be able to create a pool")
      assert(connection.pool_list.include?("test"), "Expected connection.pool_list to include test")
      pool = connection.get_pool("test")
      assert(pool.name == "test", "Expected pool to be named 'test'")
      assert(pool.ids_used == 0, "Expected pool to have no used IDs")
      ids = pool.mint(2)
      assert(ids.size == 2, "Expected to mint 2 ids with `pool.mint(2)`")
      assert(pool.close, "Expected close to be successful")
      assert(pool.open, "Expected to be able to re-open the pool")
      assert(pool.ids_used == 2, "Expected the previously minted ids to register as used")
    end

    private

    def assert(boolean_test, expectation_message)
      if boolean_test # The test passed
        logger.info expectation_message
        return true
      else
        logger.fatal "FAILED EXPECTATION: #{expectation_message}"
        raise AssertionFailedError,  "FAILED EXPECTATION: #{expectation_message}"
      end
    end
  end
end
