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
    rating_params.keys.each do |k|
      rateable_params = rating_params[k]
      rateable_class = k.constantize # constantize converts "Trip" (the string) => Trip (the Class).
      rateable = rateable_class.find(rateable_params[:id]) 
      if rateable_params[:value]
        r = rateable.rate(rater, rateable_params[:value], rateable_params[:comments])
        if r.valid?
          successful_ratings << rateable_class.name.downcase
        end
      end
    end
    flash[:notice] = t(:rating_submitted_for_approval, rateable: successful_ratings.to_sentence, count: successful_ratings.count) # only flash on creation
    if user_signed_in?
      redirect_to user_trips_path(rater) # this behaves poorly when rating an agency.  Otherwise acts right.
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
    puts "TEST"
    @trip.rate(@trip.user, params[:rating][:value], params[:rating][:comments])

    flash[:notice]= t(:thanks_for_the_feedback)
    redirect_to root_path
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

    flash[:notice] = t(:rating_update, count: parsed_ratings.count) 
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

