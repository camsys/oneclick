class RatingsController < ApplicationController

  include ApplicationHelper

  skip_before_filter :authenticate_user!
  skip_before_filter :set_locale
  skip_before_filter :get_traveler
  skip_before_filter :setup_actions
  skip_after_filter :clear_location

  def comments
    @trip = Trip.find(params[:id].to_i)
    @trip.user_comments = params['trip']['user_comments']
    @trip.save
    respond_to do |format|
      format.html { redirect_to(root_path, :flash => { :notice => "Thank you for providing feedback about your trip."}) }
      format.json { head :no_content }
    end
  end

  def admin_comments
    @trip = Trip.find(params[:id].to_i)
    @trip.user_comments = params['trip']['user_comments']
    @trip.save
    respond_to do |format|
      format.html { redirect_to(admin_trips_path, :flash => { :notice => t(:comments_updated)}) }
      format.json { head :no_content }
    end
  end

  def rate
    @trip = Trip.find(params[:id])
    @traveler = User.find(params[:user_id])
    @trip.rating = params[:stars].to_i
    @trip.save

    size = params[:size] || 1

    new_icon = get_rating_icons(@trip,size)

    respond_to do |format|
      format.html { redirect_to(root_path) }
      format.js {render inline: "$('#star" + @trip.id.to_s + "_" + @trip.rating.to_s + "').closest('span').replaceWith(\"" + new_icon + "\");" }
    end
  end

  def index
    @trip = Trip.find(params[:id])
    @traveler = User.find(params[:user_id])

    unless @trip.md5_hash == params[:hash]
      render text: t(:error_404), status: 404
      return
    end

    if params[:taken] == 'true'
      @trip.taken = true
    elsif params[:taken] == 'false'
      @trip.taken = false
    else
      @trip.taken = nil
    end
    @trip.save

    respond_to do |format|
      format.html
      format.json { render json: @trip }
    end

  end
end

