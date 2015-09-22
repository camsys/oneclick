class UserServicesController < ApplicationController
  def create

    service =  Service.find(params['user_service']['service_id'].to_i)
    external_client_id = params['user_service']['external_client_id']
    external_client_password = params['user_service']['external_client_password']
    @traveler = User.find(params['user_service']['user_id'].to_i)

    result = service.associate_user(@traveler, external_client_id, external_client_password)
    message = (result ? "" : "Incorrect username or password")

    ## Needed for booking: Return an array of trip_purposes
    if result
      user_service = UserService.find_by(user_profile: @traveler.user_profile, service: service)
      trip_purposes = user_service.get_booking_trip_purposes
      passenger_types = user_service.get_passenger_types
      space_types = user_service.get_space_types

    else
      trip_purposes = {}
      passenger_types = {}
      space_types  = {}
    end


    respond_to do |format|
      format.json { render json: {associated: result, message: message, trip_purposes: trip_purposes, passenger_types: passenger_types, space_types: space_types} }
    end
  end
end
