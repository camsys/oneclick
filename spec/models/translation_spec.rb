require 'spec_helper'

describe Translation do
  it "can handle two of the same key within different locales" do
    FactoryGirl.create(:en_cms_snippet).should have(0).errors_on(:key)
    FactoryGirl.build(:es_cms_snippet).should have(0).errors_on(:key)
  end

  it "can handle two of the same key within the same locale" do
    FactoryGirl.create(:en_cms_snippet).should have(0).errors_on(:key)
    FactoryGirl.build(:en_cms_snippet).should have(1).errors_on(:key)
  end
end
