class RatingsController < ApplicationController

  before_filter :get_rateable, only: [:new]
  load_and_authorize_resource only: [:index]
  
  def index
    authorize! :read, Rating
  end

  def new
    @ratings_proxy = RatingsProxy.new(@rateable)
    respond_to do |format|
      format.js { render partial: 'ratings/form', locals: {url: @target} }
    end
  end

  def create
    successful_ratings = []
      
    rating_params = params[:ratings]
    rating_params.keys.each do |k|
      rateable_params = rating_params[k]
      rateable_class = k.constantize # constantize converts "trip" (the string) => Trip (the Class).
      rateable = rateable_class.find(rateable_params[:id]) 
      if rateable_params[:value]
        r = rateable.rate(current_user, rateable_params[:value], rateable_params[:comments])
        if r.valid?
          successful_ratings << rateable_class.name.downcase
        end
      end
    end
    flash[:notice] = t(:rating_submitted_for_approval, rateable: successful_ratings.to_sentence, count: successful_ratings.count) # only flash on creation

    redirect_to :back
  end

  def context
    r = Rating.find(params[:id])
    respond_to do |format|
      format.js {render partial: "context", :formats => [:html], locals: {rateable: r.rateable} }
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
  # Quite a lot of coupling here, between routes.rb and the ratings_controller
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
    elsif params[:provider_id]
      @rateable = Provider.find(params[:provider_id])
      @target = provider_ratings_path(@rateable)
    end
  end

end

