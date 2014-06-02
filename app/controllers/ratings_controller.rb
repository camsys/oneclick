class RatingsController < ApplicationController

  before_filter :get_rateable, only: [:new]

   def new
    @ratings_proxy = RatingsProxy.new(@rateable)
    respond_to do |format|
      format.js { render partial: 'ratings/form', locals: {url: @target} }
    end
  end

  def create
    rating_params = params[:ratings]
    rating_params.keys.each do |k|
      rateable_params = rating_params[k]
      rateable_class = k.constantize # constantize converts "trip" (the string) => Trip (the Class).
      rateable = rateable_class.find(rateable_params[:id]) 
      if rateable_params[:value]
        r = rateable.rate(current_user, rateable_params[:value], rateable_params[:comments])
        flash[:notice] = t(:rating_submitted_for_approval, rateable: rateable_class.name.downcase) if r.valid? # only flash on creation
      end
    end

    redirect_to :back
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

