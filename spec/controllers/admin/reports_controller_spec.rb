require 'spec_helper'

describe Admin::ReportsController do

  before(:each) do
    login_as(:admin)
  end

  describe "GET 'index'" do
    it "returns http success" do
      get :index
      response.should be_success
    end
  end

  describe "GET 'show'" do
    it "returns http success" do
      BasicReportRow.stub(new: double('mock report', get_data: 'stuff'))
      report = create(:report)
      get :show, id: report.id
      response.should be_success
    end
  end

end
