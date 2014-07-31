require 'spec_helper'
 
describe UserMailer do
    let(:user) { FactoryGirl.build(:user2) }
    let(:trip) {FactoryGirl.create(:trip_with_selected_itineraries)}
    
    it 'emails with a complete paratransit trip' do
      func_ary = [:user_trip_email, :provider_trip_email].each do |func|
      	mail =  UserMailer.send(func, ["amagil@camsys.com", user.email], trip, "Testing Subject", "test@camsys.com", "These are the comments" )
    	## assertions have to be stacked here instead of placed in their own tests for stupid rspec syntax reasons (cannot nest "it"s)
        mail.subject.should == 'Testing Subject'
        mail.to.should == ["amagil@camsys.com", 'example2@example.com']
        mail.from.should == ['test@camsys.com']
      end
    end

    describe 'emails a user their itinerary' do
    	let(:mail) { UserMailer.user_itinerary_email( user.email, trip, trip.return_part.selected_itinerary, "Itinerary Email Subject", "test@camsys.com", "These are the comments" ) }
    	 it 'emails the right subject' do
    	 	mail.subject.should == "Itinerary Email Subject"
    	 end
    	 it 'emails the right to' do
    	 	mail.to.should == ['example2@example.com']
    	 end
    	 it 'emails the right from' do
    	 	mail.from.should == ['test@camsys.com']
    	 end
    	end
end