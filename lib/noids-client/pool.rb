module NoidsClient
  class Pool

    attr_reader :name

    def initialize(name, rest_resource)
      @name = name
      @noid_pool = rest_resource
    end

    def info
      JSON.parse(@noid_pool.get)
    end

    def open
      JSON.parse(@noid_pool['open'].put '')
    end

    def close
      JSON.parse(@noid_pool['close'].put '')
    end

    def mint(n=1)
      JSON.parse(@noid_pool['mint'].post '', params: {n: n})
    end

    def advance_past(id)
      JSON.parse(@noid_pool['advancePast'].post '', params: {id: id})
    end
  end
end
