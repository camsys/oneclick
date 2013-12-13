require 'spec_helper'

describe ItineraryDecorator do
  let(:decorator) { ItineraryDecorator.new(object) }
  let(:object) { Itinerary.create duration: 60*60 }
  describe "duration_in_words" do
    describe "in english" do
      it "creates correct string for exactly 1 hour" do
        object.duration = 60*60
        I18n.locale = :en # TODO this should be in a before(), no?
        expect(decorator.duration_in_words).to eq '1 h 0 mins (est.)'
      end
      it "creates correct string for less than 1 minute" do
        object.duration = 59
        I18n.locale = :en
        expect(decorator.duration_in_words).to eq 'Under 1 min (est.)'
      end
      it "creates correct string for an hour and some minutes" do
        I18n.locale = :en
        object.duration = (60*60)+(5*60)
        expect(decorator.duration_in_words).to eq '1 h 5 mins (est.)'
      end
      it "creates correct string for plural hours and singular minutes" do
        I18n.locale = :en
        object.duration = (2*60*60)+(1*60)
        expect(decorator.duration_in_words).to eq '2 h 1 min (est.)'
      end
      it "does the correct thing when passed a float" do
        I18n.locale = :en
        object.duration = (60*60)+(5.5*60)
        expect(decorator.duration_in_words).to eq '1 h 5 mins (est.)'
      end
      it "does the correct thing when passed nil" do
        I18n.locale = :en
        object.duration = nil
        expect(decorator.duration_in_words).to eq 'Not available'
      end
    end
    describe "in spanish" do
      it "creates correct string for an hour and some minutes" do
        I18n.locale = :es
        object.duration = (60*60)+(5*60)
        expect(decorator.duration_in_words).to eq '1 h 5 mins (est.)'
      end
      it "creates correct string for plural hours and singular minutes" do
        I18n.locale = :es
        object.duration = (2*60*60)+(1*60)
        expect(decorator.duration_in_words).to eq '2 h 1 min (est.)'
      end
    end
  end

end
