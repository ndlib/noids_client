#
# Connection remembers how to contact a given noids server
#
module NoidsClient
  class Connection
    def initialize(url)
      @noids = ::RestClient::Resource.new(url)
    end

    def new_pool(name, template)
      @noids["/pools"].post '', params: {name: name, template: template}
      get_pool(name)
    end

    def get_pool(name)
      Pool.new(name, @noids["/pools/#{name}"])
    end

    def pool_list
      JSON.parse(@noids['/pools'].get)
    end

    def stats
      JSON.parse(@noids['/stats'].get)
    end
  end
end
