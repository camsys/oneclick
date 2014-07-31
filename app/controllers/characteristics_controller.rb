class CharacteristicsController < TravelerAwareController
  before_filter :get_traveler

  def update
  # Parameters: {"utf8"=>"✓", "authenticity_token"=>"4fozeJE2OD4XRerZcDD+P0gkjs5jdQA6tMz14zAD7pU=", "user_characteristics_proxy"=>{"disabled"=>"true", "ada_eligible"=>"na", "matp"=>"na", "veteran"=>"na", "date_of_birth"=>"", "folding_wheelchair_accessible"=>"na", "motorized_wheelchair_accessible"=>"na", "curb_to_curb"=>"na"}, "user_id"=>"28", "trip_id"=>"3", "id"=>"new"}    
  # OR
  # {"user_answer"=>"true", "code"=>"ada_eligible", "user_id"=>"27"}

    input_values = normalize_input_values(params)

    @user_characteristics_proxy = UserCharacteristicsProxy.new(User.find(params[:user_id]))
    if @user_characteristics_proxy.update_maps(input_values)

      if params['inline'] == '1' || params[:trip_id]
        @trip = Trip.find(session[:current_trip_id] || params[:trip_id])
        @trip.remove_itineraries
        @path = populate_user_trip_path(@traveler, @trip, {asynch: 1}, locale: I18n.locale )
      end

      # We assume the update is from the review page if it's ajax
      if request.xhr?
        render nothing: true, status: 200
        return
      end

      respond_to do |format|
        format.html { redirect_to @path}
        format.js { render "characteristics/update_form" }
      end
    else
      @trip_id = session[:current_trip_id] || params[:trip_id]
      @trip = Trip.find(@trip_id)
      @total_steps = (@traveler.has_disability? ? 3 : 2)
      render action: :new 
    end
    
  end

  def normalize_input_values params
    return params[:user_characteristics_proxy] if params.include? :user_characteristics_proxy
    return { params[:code] => params[:user_answer] }
  end

  def new
    @user_characteristics_proxy = UserCharacteristicsProxy.new(@traveler)

    @trip_id = session[:current_trip_id] || params[:trip_id]
    @trip = Trip.find(@trip_id)
    @total_steps = (@traveler.has_disability? ? 3 : 2)

    respond_to do |format|
      format.html
    end
  end

  # TODO Not used anymore
  def header
    @total_steps = (params[:state] == 'user_characteristics_proxy_disabled_true' ? 3 : 2)
    Rails.logger.info  "total_steps: #{@total_steps}"

    respond_to do |format|
      format.html { render partial: 'header', locals: {total_steps: @total_steps}}
    end
  end
end
