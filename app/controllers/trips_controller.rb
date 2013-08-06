class TripsController < ApplicationController

  # GET /trips/1
  # GET /trips/1.json
  def show
    @trip = Trip.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @trip }
    end
  end

  # called when the user wants to hide an option. Invoked via
  # an ajax call
  def hide
    itinerary = Itinerary.find(params[:id])
    respond_to do |format|
      if itinerary
        @trip = itinerary.trip
        itinerary.hide
        format.js # hide.js.haml
      else
        render text: 'Unable to remove itinerary.', status: 500
      end
    end
  end

  # GET /trips/new
  # GET /trips/new.json
  def new
    @trip = Trip.new
    # TODO User might be different if we are an agent
    @trip.owner = current_user || anonymous_user
    @trip.build_from_place(sequence: 0)
    @trip.build_to_place(sequence: 1)

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @trip }
    end
  end

  # POST /trips
  # POST /trips.json
  def create
    params[:trip][:owner] = current_user || anonymous_user
    @trip = Trip.new(params[:trip])
    # @trip.owner = current_user || anonymous_user

    respond_to do |format|
      if @trip.save
        @trip.reload
        @trip.create_itineraries
        unless @trip.has_valid_itineraries?
          message = t(:trip_created_no_valid_options)
          details = @trip.itineraries.collect do |i|
            "<li>%s (%s)</li>" % [i.message, i.status]
          end
          message = message + '<ol>' + details.join + '</ol>'
          flash[:error] = message.html_safe
        end
        format.html { redirect_to @trip }
        format.json { render json: @trip, status: :created, location: @trip }
      else
        Rails.logger.info @trip.ai
        Rails.logger.info @trip.places.ai
        Rails.logger.info @trip.from_place.ai
        Rails.logger.info @trip.to_place.ai
        format.html { render action: "new" }
        format.json { render json: @trip.errors, status: :unprocessable_entity }
      end
    end
  end

end
