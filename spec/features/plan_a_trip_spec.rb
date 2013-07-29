require 'spec_helper'

describe "the signin process", :type => :feature do
  before :each do
    FactoryGirl.create(:user)
  end

  it "signs me in" do
    visit '/trips/new'
    # save_and_open_page
    # within("#new_trip") do
      fill_in '#trip_from_place_nongeocoded_address', :with => '730 w peachtree st, atlanta, ga'
      fill_in '#trip_to_place_nongeocoded_address', :with => 'georgia state capitol, atlanta, ga'
    # end
    click_link 'Plan it'
    expect(page).to have_content 'Success'
  end
end
