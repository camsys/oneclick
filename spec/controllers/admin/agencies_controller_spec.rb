require 'spec_helper'

describe Admin::AgenciesController do
  before (:all) do
      FactoryGirl.create(:arc_mobility_mgmt_agency)
  end

  before(:each) do
    login_as_using_find_by(email: 'email@camsys.com')
  end
  
  describe 'index' do
    it 'gets the index page successfully' do
      get :index
      response.status.should eq 200
    end
  end
end