class RatingsController < ApplicationController

  before_filter :get_rateable, only: [:new, :new_from_email]
  
  def index
    authorize! :read, Rating
    authorize! :approve, Rating
    @ratings = Rating.all
  end

  def new
    @ratings_proxy = RatingsProxy.new(@rateable, current_user)
    respond_to do |format|
      format.js { render partial: 'ratings/form', locals: {url: @target} }
    end
  end

  def create
    successful_ratings = []
    rater = current_user || User.find(params[:user][:id])
    rating_params = params[:ratings]
    first_rateable = nil
    rating_params.keys.each do |k|
      rateable_params = rating_params[k]
      rateable_class = k.constantize # constantize converts "Trip" (the string) => Trip (the Class).
      rateable = rateable_class.find(rateable_params[:id]) 
      if first_rateable.nil?
        first_rateable = rateable
      end
      if rateable_params[:value]
        r = rateable.rate(rater, rateable_params[:value], rateable_params[:comments])
        if r.valid?
          successful_ratings << rateable_class.name.downcase
        end
      end
    end
    flash[:notice] = t(:rating_submitted_for_approval, rateable: successful_ratings.to_sentence, count: successful_ratings.count) # only flash on creation
    if user_signed_in?
      if rating_params.count == 1 #only one rateable object, can assume it's either Service or Agency
        case first_rateable
        when Service
          redirect_to service_path(first_rateable)
          return
        when Agency
          redirect_to admin_agency_path(first_rateable)
          return
        end
      end

      # otherwise, assume it's from Trip rating
      # this behaves poorly when an admin was rating a trip under Staff menu (i.e., not your own trips)
      # but on the other hand, does it make sense to rate somebody else's trip?
      redirect_to user_trips_path(rater) 
    else
      redirect_to root_path
    end
  end

  def trip_only
    @trip = Trip.find(params[:trip_id])
    unless (@trip.md5_hash.eql? params[:trip][:hash]) || (authorize! :create, @trip.ratings.build(rateable: @trip))
      flash[:notice] = t(:http_404_not_found)
      redirect_to root_path
    end
    @trip.rate(@trip.user, params[:rating][:value], params[:rating][:comments])

    flash[:notice]= t(:thanks_for_the_feedback)
    redirect_to user_trip_path_for_ui_mode(@traveler, @trip)
  end

  def context
    r = Rating.find(params[:id])
    respond_to do |format|
      format.js {render partial: "context", :formats => [:html], locals: {r: r} }
    end
  end

  def approve
    authorize! :approve, Rating
    parsed_ratings = Rack::Utils.parse_query(params[:approve]) # data serialized for AJAX call.  Must parse from query-string
    parsed_ratings.each do |k,v|
      Rating.find(k).update_attributes(status: v)
    end

    flash[:notice] = t(:rating_update, count: parsed_ratings.count) if parsed_ratings.count != 0
    respond_to do |format|
      format.js {render nothing: true}
      format.html {redirect_to action: :index}
    end
  end

private

  # Get the rateable object from the params hash.  Ratings controller can be accessed through multiple rateables.  
  def get_rateable
    if params[:trip_id]
      @rateable = Trip.find(params[:trip_id])
      @target = trip_ratings_path(@rateable)
    elsif params[:agency_id]
      @rateable = Agency.find(params[:agency_id])
      @target = agency_ratings_path(@rateable)
    elsif params[:service_id]
      @rateable = Service.find(params[:service_id])
      @target = service_ratings_path(@rateable)
    end
  end

end

