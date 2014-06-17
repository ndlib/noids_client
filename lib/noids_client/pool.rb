require 'date'

module NoidsClient
  class Pool

    attr_reader :name, :template, :ids_used, :max_ids, :last_mint_date

    def initialize(rest_resource)
      @noid_pool = rest_resource
      update
    end

    def update
      decode_json(@noid_pool.get)
    end

    def open
      decode_json(@noid_pool['open'].put '')
    end

    def close
      decode_json(@noid_pool['close'].put '')
    end

    def closed?
      @is_closed
    end

    def mint(this_many_ids=1)
      JSON.parse(@noid_pool['mint'].post '', params: {n: this_many_ids})
    end

    def advance_past(this_id)
      decode_json(@noid_pool['advancePast'].post '', params: {id: this_id})
    end

    private
    def decode_json(json_string)
      info = JSON.parse(json_string)
      @name = info['Name']
      @template = info['Template']
      @ids_used = info['Used']
      @max_ids = info['Max']
      if @max_ids == -1
        @max_ids = Float::INFINITY
      end
      @is_closed = info['Closed']
      @last_mint_date = DateTime.rfc3339(info['LastMint'])
    end
  end
end
