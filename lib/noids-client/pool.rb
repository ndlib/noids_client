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

    def mint(this_many_ids=1)
      JSON.parse(@noid_pool['mint'].post '', params: {n: this_many_ids})
    end

    def advance_past(this_id)
      JSON.parse(@noid_pool['advancePast'].post '', params: {id: this_id})
    end
  end
end
