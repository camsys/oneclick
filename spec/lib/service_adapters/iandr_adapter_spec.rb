require 'spec_helper'
# include ServiceAdapters::IandrAdapter

describe ServiceAdapters::IandrAdapter do
  it "create example xml" do
    p = Provider.new
    p.services << Service.new
    i = ServiceAdapters::IandrAdapter.new([p])
    # TODO this doesn't current have a real test, I just use it to generate sample XML
    # puts i.to_xml(indent: 2)
    # i.to_xml.should eq 'foo'
  end
end
