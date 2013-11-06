require 'spec_helper'
# include ServiceAdapters::IandrAdapter

describe ServiceAdapters::IandrAdapter do
  it "create example xml" do
    p = Provider.new
    p.services << Service.new
    i = ServiceAdapters::IandrAdapter.new([p])
    puts i.to_xml(indent: 2)
    i.to_xml.should eq 'foo'
  end
end
