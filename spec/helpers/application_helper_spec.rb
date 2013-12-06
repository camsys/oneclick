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

  describe "duration_to_words" do
    describe "in english" do
      it "creates correct string for exactly 1 hour" do
        I18n.locale = :en # TODO this should be in a before(), no?
        duration_to_words(60*60).should eq '1 h 0 mins'
      end
      it "creates correct string for less than 1 minute" do
        I18n.locale = :en
        duration_to_words(59).should eq 'Under 1 min'
      end
      it "creates correct string for an hour and some minutes" do
        I18n.locale = :en
        duration_to_words((60*60)+(5*60)).should eq '1 h 5 mins'
      end
      it "creates correct string for plural hours and singular minutes" do
        I18n.locale = :en
        duration_to_words((2*60*60)+(1*60)).should eq '2 h 1 min'
      end
      it "does the correct thing when passed a float" do
        I18n.locale = :en
        duration_to_words((60*60)+(5.5*60)).should eq '1 h 5 mins'
      end
      it "does the correct thing when passed nil" do
        I18n.locale = :en
        duration_to_words(nil).should eq 'n/a'
      end
    end
    describe "in spanish" do
      it "creates correct string for an hour and some minutes" do
        I18n.locale = :es
        duration_to_words((60*60)+(5*60)).should eq '1 h 5 mins'
      end
      it "creates correct string for plural hours and singular minutes" do
        I18n.locale = :es
        duration_to_words((2*60*60)+(1*60)).should eq '2 h 1 min'
      end
    end
  end

  it "returns correct trip itinerary direction icon" do
    trip = FactoryGirl.create(:round_trip)
    trip.trip_parts.first.itineraries << FactoryGirl.create(:itinerary)
    trip.trip_parts.last.itineraries << FactoryGirl.create(:itinerary)
    get_trip_direction_icon(trip.trip_parts.first.itineraries.first).should eq 'icon-arrow-right'
    get_trip_direction_icon(trip.trip_parts.last.itineraries.first).should eq 'icon-arrow-left'
  end

end
