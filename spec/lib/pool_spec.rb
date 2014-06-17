require 'spec_helper'

describe NoidsClient::Pool do
  it "decodes json" do
    response = %q{{"Name":"abc","Template":".zeee+0","Used":0,"Max":-1,"Closed":false,"LastMint":"2014-06-16T14:27:19.022553001-04:00"}}
    rest_resource = double("rest_resource", get: response)
    pool = NoidsClient::Pool.new(rest_resource)
    expect(pool.name).to eq("abc")
    expect(pool.template).to eq(".zeee+0")
    expect(pool.ids_used).to eq(0)
    expect(pool.max_ids).to eq(Float::INFINITY)
    expect(pool.closed?).to be_falsey
    expect(pool.last_mint_date).to be_a(DateTime)
    expect(pool.last_mint_date.day).to eq(16)
  end
end
