class TripPartsController < PlaceSearchingController
  include TripsSupport
  include TripsHelper

  before_filter :get_traveler
  before_filter :get_trip

  def unselect_all
    trip_part = TripPart.find(params[:id])
    Rails.logger.info trip_part.ai
    trip_part.itineraries.selected.each do |i|
      Rails.logger.info i.ai
      i.update_attribute :selected, false
      Rails.logger.info i.ai
    end
    Rails.logger.info ""
    redirect_to user_trip_path_for_ui_mode(@traveler, trip_part.trip)
  end

  # Unhides all the hidden itineraries for a trip part
  def unhide_all
    trip_part = TripPart.find(params[:id])
    trip_part.itineraries.valid.hidden.each do |i|
      i.hidden = false
      i.save
    end
    redirect_to user_trip_path_for_ui_mode(@traveler, trip_part.trip)
  end

  def itineraries
    @trip_part = TripPart.find(params[:id])
    @modes = Mode.where(code: params[:mode])
    params[:regen] = (params[:regen] || false).to_bool
    if params[:regen]
      @trip_part.remove_existing_itineraries(@modes)
    end
    @itineraries = @trip_part.itineraries.where('mode_id in (?)', @modes.pluck(:id))
    Rails.logger.info "trip part has #{@itineraries.count} itineraries for modes #{@modes.map(&:code).join(', ')}."

    if (@itineraries.empty?)
      Rails.logger.info "itineraries is empty, generating itineraries."

      @itineraries = @trip_part.create_itineraries(@modes)
      #end
    else
      Rails.logger.info "itineraries is not empty, not generating itineraries."
    end

    @itineraries = filter_itineraries_by_max_offset_time(@itineraries, @trip_part.is_depart, @trip_part.trip_time)
    if @itineraries.each {|i| i.save }
      respond_to do |f|
        f.json { render json: @itineraries, root: 'itineraries', each_serializer: ItinerarySerializer }
      end
    else
      respond_to do |f|
        f.json {
          render json:       {
            status: 0,
            status_text: @itineraries.collect{|i| i.errors}
          }
        }
      end
    end
  end

  def reschedule
    @trip_part = TripPart.find(params[:id])

    begin
      raise "minutes must be specified" unless params[:minutes]
      @trip_part.reschedule(params[:minutes])
      render json: {
        status: 200,
        trip_part_time: @trip_part.scheduled_time.iso8601
        }, status: 200
    rescue Exception => e
      render json: {
          status: 409,
          message: e.message
        }, status: 409
    end
  end

end
