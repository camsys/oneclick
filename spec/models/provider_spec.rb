require 'spec_helper'

describe Provider do
  let(:provider_organization1) { FactoryGirl.create(:provider)}
  let(:provider_organization2) { FactoryGirl.create(:provider)}
  let(:user) {FactoryGirl.create(:user)}

  describe "providers cannot be in hierarchy" do
    it 'should not be valid' do
      expect{provider_organization1.update_attribute(:parent, provider_organization2)}.to raise_error
    end
  end
end
