require 'spec_helper'

describe Itinerary do
  describe "duration_to_words" do
    describe "in english" do
      it "creates correct string for exactly 1 hour" do
        I18n.locale = :en # TODO this should be in a before(), no?
        i = Itinerary.new
        i.duration_to_words(60*60).should eq '1 hour 0 minutes'
      end
      it "creates correct string for less than 1 minute" do
        I18n.locale = :en
        i = Itinerary.new
        i.duration_to_words(59).should eq 'less than 1 minute'
      end
      it "creates correct string for an hour and some minutes" do
        I18n.locale = :en
        i = Itinerary.new
        i.duration_to_words((60*60)+(5*60)).should eq '1 hour 5 minutes'
      end
      it "creates correct string for plural hours and singular minutes" do
        I18n.locale = :en
        i = Itinerary.new
        i.duration_to_words((2*60*60)+(1*60)).should eq '2 hours 1 minute'
      end
      it "does the correct thing when passed a float" do
        I18n.locale = :en
        i = Itinerary.new
        i.duration_to_words((60*60)+(5.5*60)).should eq '1 hour 5 minutes'
      end
      it "does the correct thing when passed nil" do
        I18n.locale = :en
        i = Itinerary.new
        i.duration_to_words(nil).should eq 'n/a'
      end
    end
    describe "in spanish" do
      it "creates correct string for an hour and some minutes" do
        I18n.locale = :es
        i = Itinerary.new
        i.duration_to_words((60*60)+(5*60)).should eq '1 hora 5 minutos'
      end
      it "creates correct string for plural hours and singular minutes" do
        I18n.locale = :es
        i = Itinerary.new
        i.duration_to_words((2*60*60)+(1*60)).should eq '2 horas 1 minuto'
      end
    end
  end
end
