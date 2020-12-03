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
  module IntegrationTest
    class AssertionFailedError < RuntimeError
    end
    def self.default_logger
      require 'logger'
      Logger.new(STDOUT)
    end

    # @params spawn_noids_server [Boolean] rely on this script (and a configured
    #           machine) to launch a new noids server
    # @params logger [Logger] to report all the details
    #
    # @see TestRunner#initialize for kwargs options
    # @see NoidServerRunner#initialize for kwargs options
    #
    # @raises AssertionFailedError if any of the integration tests fail
    # @return true if all integration tests pass
    def self.run(spawn_noids_server: false, logger: default_logger, **kwargs)
      if spawn_noids_server
        NoidServerRunner.new(logger: logger, **kwargs).run do
          TestRunner.new(logger: logger, **kwargs).run
        end
      else
        TestRunner.new(logger: logger, **kwargs).run
      end
    end


    # A utility class to help running a NOIDs server within the context
    #
    # @example
    #   require 'noids_client/integration_test'
    #   NoidsClient::IntegrationTest::NoidServerRunner.new do
    #     # thing that requires a noids server
    #   end
    #
    class NoidServerRunner
      # @param kwargs [Hash] the configuration options for the NoidsServer. Note,
      #           you shouldn't need to pass parameters if you follow the noids
      #           documentation
      # @option logger [#debug, #info]
      # @option storage_dir [String]
      # @option file_utils [#mkdir_p, #rm_rf] the object that will manage cleaning
      #           the storage_dir
      # @option noids_command [String] the fully expanded to the noids command
      # @option seconds_to_wait [Integer] how long to wait for the noids server to
      #           fully boot
      def initialize(**kwargs)
        @logger = kwargs.fetch(:logger) { IntegrationTest.default_logger }
        logger.debug("logger: #{logger.inspect}")
        @storage_dir = kwargs.fetch(:storage_dir) { default_storage_dir }
        logger.debug("storage_dir: #{storage_dir.inspect}")
        @file_utils = kwargs.fetch(:file_utils) { default_file_utils }
        logger.debug("file_utils: #{file_utils.inspect}")
        @noids_command = kwargs.fetch(:noids_command) { default_noids_command }
        logger.debug("noids_command: #{noids_command.inspect}")
        @seconds_to_wait = kwargs.fetch(:seconds_to_wait) { SECONDS_TO_WAIT }
        logger.debug("seconds_to_wait: #{seconds_to_wait}")
      end

      attr_reader :storage_dir, :noids_command, :logger, :file_utils, :seconds_to_wait

      private

      def default_storage_dir
        File.join(ENV.fetch("HOME"), "noids_pool")
      end

      def default_noids_command
        File.join(ENV.fetch("GOPATH"), "bin/noids")
      end

      def default_file_utils
        require 'fileutils'
        FileUtils
      end

      public

      SECONDS_TO_WAIT = 5
      def run
        clean_storage!
        process_id = Process.spawn("#{noids_command} --storage #{storage_dir}")
        Process.detach(process_id)
        logger.debug("Waiting #{seconds_to_wait} seconds for noids to start")
        sleep(seconds_to_wait)
        yield if block_given?
      ensure
        stop_noids!(process_id: process_id)
      end

      private

      def clean_storage!
        logger.info("Cleaning noids: #{storage_dir}")
        file_utils.rm_rf(storage_dir)
        file_utils.mkdir_p(storage_dir)
      end

      def start_noids!
        # `$GOPATH/bin/noids --storage ~/noids_pool`
        logger.info("Starting noids server…")
        IO.popen("#{noids_command} --storage #{storage_dir}", err: [:child, :out])
      end

      def stop_noids!(process_id:)
        logger.info("Shutting down server…")
        Process.kill(:SIGINT, process_id)
        return true
      end
    end


    class TestRunner
      # @param kwargs [Hash] the configuration options for the NoidsServer. Note,
      #           you shouldn't need to pass parameters if you follow the noids
      #           documentation
      # @option logger [#debug, #info]
      # @option noids_url [String]
      # @option connection_class [#new] a connection class that implements the
      #           NoidsClient::Connection object interface
      def initialize(**kwargs)
        @logger = kwargs.fetch(:logger) { IntegrationTest.default_logger }
        logger.debug("logger: #{logger.inspect}")
        @noids_url = kwargs.fetch(:noids_url) { default_noids_url }
        @connection_class = kwargs.fetch(:connection_class) { default_connection_class }
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
        return true
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
end
