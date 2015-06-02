require 'spec_helper'

describe Translation do
  it "can handle two of the same key within different locales" do
    FactoryGirl.create(:translation_two).should have(0).errors_on(:translation_key_id)
    FactoryGirl.create(:translation_four).should have(0).errors_on(:translation_key_id)
  end

  it "can't handle two of the same key within the same locale" do
    puts FactoryGirl.create(:translation_two).should have(0).errors_on(:translation_key_id)
    puts FactoryGirl.build(:translation_three).should have(1).errors_on(:translation_key_id)
  end
end
