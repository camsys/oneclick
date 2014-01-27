require 'spec_helper'

describe Organization do
  let(:agency_organization1) { FactoryGirl.create(:agency_organization)}
  let(:agency_organization2) { FactoryGirl.create(:agency_organization)}
  let(:provider_organization1) { FactoryGirl.create(:provider_organization)}
  let(:provider_organization2) { FactoryGirl.create(:provider_organization)}
  let(:user) {FactoryGirl.create(:user)}

  subject{agency_organization1}

  it { should be_valid }

  describe "agency organizations can be in hierarchy" do
    before {agency_organization1.update_attribute(:parent, agency_organization2)}
    it { should be_valid }
  end

  describe "provider organizations cannot be in hierarchy" do
    it 'should not be valid' do
      expect{provider_organization1.update_attribute(:parent, provider_organization2)}.to raise_error
      # provider_organization1.should_not be_valid
    end
  end

  # TODO This should be in user tests?
  describe "user can belong to an agency and a provider" do
    it 'should not be valid to assign provider as agency for a user' do
      user.update_attribute(:agency, provider_organization1)
      user.should_not be_valid
    end
    it 'should not be valid to assign agency as provider for a user' do
      user.update_attribute(:provider, agency_organization1)
      user.should_not be_valid
    end
    it 'should be valid' do
      user.agency = agency_organization1
      user.provider = provider_organization1
      user.save!
      user.should be_valid
    end
  end
  # describe "user cannot belong to more than one agency or more than one provider" do

  # end
end
