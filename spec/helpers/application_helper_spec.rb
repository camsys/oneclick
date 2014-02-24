require 'spec_helper'

describe ApplicationHelper do

  it "should return correct link_using_locale when there is no locale in the path" do
    I18n.locale = :en
    I18n.locale.should eq(:en)
    helper.request = double(fullpath: "/")
    helper.link_using_locale("Espanol", :es).should eq(%Q{<a href="/es">Espanol</a>})
  end

  it "should return correct link_using_locale when there is a locale in the path" do
    I18n.locale = :es
    I18n.locale.should eq(:es)
    helper.request = double(fullpath: "/es/sign_up")
    helper.link_using_locale("English", :en).should eq(%Q{<a href="/en/sign_up">English</a>})
    I18n.locale = :en
  end

  it "should not include a link for the language that is already selected" do
    I18n.locale = :en
    I18n.locale.should eq(:en)
    helper.request = double(fullpath: "/")
    helper.link_using_locale("English", :en).should eq(%Q{English})
    helper.link_using_locale("Espanol", :es).should eq(%Q{<a href="/es">Espanol</a>})
  end

  it "should not include a link for the language that is already selected (not home page, default language)" do
    I18n.locale = :en
    I18n.locale.should eq(:en)
    helper.request = double(fullpath: "/trips/new")
    helper.link_using_locale("English", :en).should eq(%Q{English})
    helper.link_using_locale("Espanol", :es).should eq(%Q{<a href="/es/trips/new">Espanol</a>})
  end

  it "should not include a link for the language that is already selected (not home page)" do
    I18n.locale = :es
    I18n.locale.should eq(:es)
    helper.request = double(fullpath: "/es/sign_up")
    helper.link_using_locale("English", :en).should eq(%Q{<a href="/en/sign_up">English</a>})
    helper.link_using_locale("Espanol", :es).should eq(%Q{Espanol})
    I18n.locale = :en
  end

  it "returns correct trip itinerary direction icon" do
    trip = FactoryGirl.create(:round_trip)
    trip.trip_parts.first.itineraries << FactoryGirl.create(:itinerary)
    trip.trip_parts.last.itineraries << FactoryGirl.create(:itinerary)
    get_trip_direction_icon(trip.trip_parts.first.itineraries.first).should eq 'fa-arrow-right'
    get_trip_direction_icon(trip.trip_parts.last.itineraries.first).should eq 'fa-arrow-left'
  end

end
