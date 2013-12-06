class RatingsController < ApplicationController

  skip_before_filter :authenticate_user!

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
    @trip.rate(params[:stars],  @traveler, params[:dimension])

    respond_to do |format|
      format.html { redirect_to(root_path) }
      format.js {render inline: "location.reload();" }
    end
  end

  def index
    @trip = Trip.find(params[:id])
    @traveler = User.find(params[:user_id])

    unless @trip.md5_hash == params[:hash]
      render text: t(:error_404), status: 404
      return
    end

    respond_to do |format|
      format.html
      format.json { render json: @trip }
    end

  end
end

