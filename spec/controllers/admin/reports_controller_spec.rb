require 'spec_helper'

describe Admin::ReportsController do

  before(:each) do
    login_as(:admin)
  end

  describe "GET 'show'" do
    it "returns http success" do
      BasicReportRow.stub(new: double('mock report', get_data: 'stuff', get_columns: [], paged: false))
      report = create(:report)
      get :show, id: report.id, generated_report: {report_name: report.id}
      response.should be_success
    end
  end

end
