require 'spec_helper'

describe Agency do
  let(:agency_organization1) { FactoryGirl.create(:arc_agency)}
  let(:agency_organization2) { FactoryGirl.create(:arc_mobility_mgmt_agency)}
  let(:user) {FactoryGirl.create(:user)}

  subject{agency_organization1}

  it { should be_valid }

  describe "agencies can be in hierarchy" do
    before {agency_organization1.update_attribute(:parent, agency_organization2)}
    it { should be_valid }
  end


end