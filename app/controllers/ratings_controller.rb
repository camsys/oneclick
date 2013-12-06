class RatingsController < ApplicationController


  def comments
    @trip = Trip.find(params[:id].to_i)
    @trip.user_comments = params['trip']['user_comments']
    @trip.save
    respond_to do |format|
      format.html { redirect_to(user_trips_path(@traveler), :flash => { :notice => t(:comments_sent)}) }
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
    @trip.rate(params[:stars], current_user, params[:dimension])

    respond_to do |format|
      format.html { redirect_to(user_trips_path(@traveler)) }
      format.js {render inline: "location.reload();" }
    end

  end

  def edit_rating

    @trip = Trip.find(params[:id])
    @traveler = User.find(params[:user_id])
    #if @trip.md5_hash == params[:hash]
    #  @current_user ||= @traveler
    #end
    respond_to do |format|
      format.html
      format.json { render json: @trip }
    end

  end
end

