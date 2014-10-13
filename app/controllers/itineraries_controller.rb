
class ItinerariesController < ApplicationController
  include MapHelper

  def map_status
    statuses = Itinerary.where(id: params[:id].split(',')).collect{|i| {id: i.id, has_map: !i.map_image.url.nil?, url: i.map_image.url}}
    render json: statuses
  end

  def request_create_map
    itin_id = params[:id]
    ids = params[:id].split(',')
    ids.each do |id|
      print_url = create_map_user_trip_itinerary_url(params[:user_id], params[:trip_id], id.to_s)
      Rails.logger.info "print_url is #{print_url}"
      PrintMapWorker.perform_async(print_url, id)
    end
    render json: {}
  end

  def create_map
    Rails.logger.info "create_map"
    Rails.logger.info request.headers.ai
    @trip = Trip.find(params[:trip_id])
    @itinerary = @trip.itineraries.valid.find(params[:id])
    @legs = @itinerary.get_legs
    if @itinerary.is_mappable
      @markers = create_itinerary_markers(@itinerary).to_json
      @polylines = create_itinerary_polylines(@legs).to_json
      @sidewalk_feedback_markers = create_itinerary_sidewalk_feedback_markers(@legs).to_json
    end

    @itinerary = ItineraryDecorator.decorate(@itinerary)
    render
  end

  def get_trip
    Rails.logger.info "get_trip"
    @trip = Trip.find(params[:trip_id])
  end

  def get_itinerary
    Rails.logger.info "get_itinerary"
    @itinerary = @trip.itineraries.valid.find(params[:id])
  end

end
