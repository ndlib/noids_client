#
# Connection remembers how to contact a given noids server
#
module NoidsClient
  class Connection

    attr_reader :server_version

    def initialize(url)
      @noids = ::RestClient::Resource.new(url)
      update
    end

    def new_pool(name, template)
      @noids['pools'].post '', params: {name: name, template: template}
      get_pool(name)
    end

    def get_pool(name)
      Pool.new(@noids["pools/#{name}"])
    end

    def pool_list
      JSON.parse(@noids['pools'].get)
    end

    def update
      parse_stats(@noids['stats'].get)
    end

    private
    def parse_stats(json_string)
      stats = JSON.parse(json_string)
      @server_version = stats['Version']
    end
  end
end
