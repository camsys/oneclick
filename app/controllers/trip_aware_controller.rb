# 
# Abstract controller that is used as the base class
# for any concrete controllers that are based on an trip
#
class TripAwareController < ApplicationController
  # set the @trip variable before any actions are invoked
  before_filter :get_trip
        
          
protected
    
  # Sets the @trip variable to the trip that has been selected by the user. The trip must
  # belong to the user. The query returns nil if the trip is not found in the 
  # users list of trips
  #
  def get_trip

    trip = current_user.trips.find(params[:trip_id])
    if trip.nil?
      redirect_to(user_trips_url, :flash => { :alert => 'Record not found!'})
      return
    else
      @trip = trip
    end
  end
end
