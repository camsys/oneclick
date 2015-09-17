class UserServicesController < ApplicationController
  def create

    service =  Service.find(params['user_service']['service_id'].to_i)
    external_client_id = params['user_service']['external_client_id']
    external_client_password = params['user_service']['external_client_password']
    @traveler = User.find(params['user_service']['user_id'].to_i)

    result = service.associate_user(@traveler, external_client_id, external_client_password)
    message = (result ? "" : "Incorrect username or password")

    respond_to do |format|
      format.json { render json: {associated: result, message: message} }
    end
  end
end
