require 'spec_helper'

describe "Integration" do
  it "handles a normal situation correctly" do
    VCR.use_cassette('integration-1') do
      c = NoidsClient::Connection.new('http://localhost:13001')
      expect(c.pool_list).to be_a(Array)
      expect(c.pool_list).to be_empty
      p = c.new_pool("abcd", ".sddd")
      expect(p.name).to eq("abcd")
      expect(p.template).to eq(".sddd+0")
      expect(p.closed?).to be_falsy
      expect(p.ids_used).to eq(0)
      expect(p.max_ids).to eq(1000)
      p.advance_past("100")
      expect(p.ids_used).to eq(101)
      expect(p.mint(2)).to eq(["101", "102"])
      p.close
      expect(p.closed?).to be_truthy
      expect {p.mint}.to raise_error
    end
  end
end
