require 'spec_helper'

describe Admin::AgencyUserRelationshipsController do
  before (:all) do
      FactoryGirl.create(:arc_mobility_mgmt_agency)
  end

  before (:each) do
      login_as_using_find_by(email: 'email@camsys.com')
  end
end
