require 'spec_helper'

describe ItineraryDecorator do
  before(:each) do
    FactoryGirl.create :mode_paratransit
  end
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
        expect(decorator.duration_in_words).to eq ''
      end
      it "gives Book Ahead notes in days when > 24 hours" do
        I18n.locale = :en
        service = Service.new advanced_notice_minutes: 60*24 + 60, max_advanced_book_minutes: 60*24*2 + 60
        object.mode = Mode.paratransit
        object.service = service
        expect(decorator.notes).to eq '1 to 2 days'
      end
      it "gives Book Ahead notes in days when > 24 hours (more than 1 day)" do
        I18n.locale = :en
        service = Service.new advanced_notice_minutes: 60*24*3,  max_advanced_book_minutes: 60*24*5 + 60
        object.mode = Mode.paratransit
        object.service = service
        expect(decorator.notes).to eq '3 to 5 days'
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
