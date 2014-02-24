class Kiosk::LocationsController < ApplicationController
  def show
    render json: KioskLocation.find_by_name!(params[:id])
  end
end
