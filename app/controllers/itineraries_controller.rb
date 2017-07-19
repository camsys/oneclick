
class ItinerariesController < ApplicationController
  include MapHelper

  def map_status
    statuses = Itinerary.where(id: params[:id].split(',')).collect{|i| {id: i.id, has_map: true, url: i.map_image}}
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


  def book

    @itinerary = Itinerary.find(params[:id].to_i)
    @trip_part = @itinerary.trip_part

    @form_data = params[:form_data]

    case @itinerary.service.booking_profile

      when BookingServices::AGENCY[:ecolane]

        ecolane_booking = EcolaneBooking.where(itinerary: @itinerary).first_or_create

        @form_data.each do |object|

          #This is an placeholder for when/if Ecolane Bookings is brought back to the desktop interface
          case object.last[:name]
            when "trip_part[booking_trip_purpose_id]"
              @trip_part.booking_trip_purpose_id = object.last[:value].to_bool
              @trip_part.save
          end
        end

        ecolane_booking.save

      when BookingServices::AGENCY[:trapeze]

        trapeze_booking = TrapezeBooking.where(itinerary: @itinerary).first_or_create

        @form_data.each do |object|

          case object.last[:name]
            when "trip_part[booking_trip_purpose_id]"
              @trip_part.booking_trip_purpose_id = object.last[:value].to_i
              @trip_part.save
            when "trip_part[unit]"
              @trip_part.from_trip_place.unit = object.last[:value]
              @trip_part.from_trip_place.save
            when "trip_part[passenger1_type]"
              trapeze_booking.passenger1_type = (object.last[:value]).split('%%').first
              trapeze_booking.fare1_type_id = (object.last[:value]).split('%%').last
            when "trip_part[passenger2_type]"
              trapeze_booking.passenger2_type = (object.last[:value]).split('%%').first
              trapeze_booking.fare2_type_id = (object.last[:value]).split('%%').last
            when "trip_part[passenger3_type]"
              trapeze_booking.passenger3_type = (object.last[:value]).split('%%').first
              trapeze_booking.fare3_type_id = (object.last[:value]).split('%%').last
            when "trip_part[passenger1_space_type]"
              trapeze_booking.passenger1_space_type = object.last[:value]
            when "trip_part[passenger2_space_type]"
              trapeze_booking.passenger2_space_type = object.last[:value]
            when "trip_part[passenger3_space_type]"
              trapeze_booking.passenger3_space_type = object.last[:value]
          end
        end

        trapeze_booking.save

      when BookingServices::AGENCY[:ridepilot]

        ridepilot_booking = RidepilotBooking.where(itinerary: @itinerary).first_or_create

        @form_data.each do |object|
          case object.last[:name]
            when "trip_part[booking_trip_purpose_code]"
              ridepilot_booking.trip_purpose_code = object.last[:value]
            when "trip_part[guests]"
              ridepilot_booking.guests = object.last[:value].to_i
            when "trip_part[attendants]"
              ridepilot_booking.attendants = object.last[:value].to_i
            when "trip_part[mobility_devices]"
              ridepilot_booking.mobility_devices = object.last[:value].to_i
          end
        end

        ridepilot_booking.save
    end

    respond_to do |format|
      format.json { render json: @itinerary.book }
    end

  end

end
