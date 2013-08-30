class UserCharacteristicsProxiesController < ApplicationController

  def passenger_characteristics_index

    @passenger = Passenger.find(params[:passenger_id])

    @characteristics_maps = @passenger.user_profile.user_traveler_characteristics_maps

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @characteristics_maps }

  end

end
