require "spec_helper"

describe "routes for Reports" do

  context 'index' do
    subject { {get: "/admin/reports"} }
    it { should route_to(controller: "admin/reports", action: "index") }
  end

  context 'show' do
    subject { {get: "/admin/reports/29"} }
    it { should route_to(controller: "admin/reports", action: "show", id: '29') }
  end

end
