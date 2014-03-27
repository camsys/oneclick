class PlacesController < PlaceSearchingController
  
  # set the @traveler variable for actions that are not supported by the super class controller
  before_filter :get_traveler, :only => [:index, :edit, :create, :destroy, :update]
  
  def index
    
    # set the basic form variables
    set_form_variables

  end

  # Edit
  def edit
    place = @traveler.places.find(params[:edit_place_id])
    @place_proxy = create_place_proxy(place)
    @places = @traveler.places
    @markers = generate_map_markers(@places)
    
    respond_to do |format|
      format.html {render "index"}
    end
        
  end

  # not really a destroy -- just hides the place by setting active = false
  def destroy
    j = JSON.parse(params[:json])    
    place = @traveler.places.find(j['id'])
    if place
      place.active = false
      if place.save
        flash[:notice] = t(:address_book_updated)
      else
        flash[:alert] = t(:error_updating_addresses)
      end
    end

    # set the basic form variables
    set_form_variables

    respond_to do |format|
      format.html { redirect_to(user_places_path(@traveler)) } 
      format.json { head :no_content }
      format.js {render "update_form_and_map"}
    end
  end

  def create

    j = JSON.parse(params[:json])
    if j['type_name']=='PLACES_AUTOCOMPLETE_TYPE'
      Rails.logger.info "Was autocompleted, creating new"
      details = get_places_autocomplete_details(j['id'])
      d = cleanup_google_details(details.body['result'])
      Rails.logger.info d
      j = j.merge!(d).keep_if {|k, v| %w{raw_address address1 address2 city state zip lat lon county}.include? k}
      place = Place.create!(j.merge({name: params[:place_name], user: @traveler}))
      place.update_attribute(:raw_address, place.get_address)
    else
      Rails.logger.info "updating"
      place = Place.find(j['id'])
      j.delete 'id'
      place.update_attributes!(j.merge({name: params[:place_name]}))
    end

    Rails.logger.info place.ai

    # # inflate a place proxy object from the form params
    # @place_proxy = PlaceProxy.new(params[:place_proxy])
       
    # if @place_proxy.valid?
    #   place = create_place(@place_proxy)
    # end

    # set the basic form variables
    set_form_variables

    respond_to do |format|
      if place
        if place.save
          format.html { redirect_to user_places_path(@traveler), :notice => t(:address_book_updated)  }          
          format.json { render :json => place, :status => :created, :location => place }
        else
          format.html { render action: "index" }
          format.json { render json: @place_proxy.errors, status: :unprocessable_entity }
        end
      else
        format.html { render action: "index", flash[:alert] => t(:nothing_found) }
      end
    end
  end
  
  def handle
    if params[:save]
      create
    elsif params[:delete]
      destroy
    end
  end

  # updates a place
  def update

    # get the place being updated
    place = @traveler.places.find(params[:id])
    Rails.logger.debug place.inspect
    
    # get a place proxy from the place
    @place_proxy = create_place_proxy(place)
    Rails.logger.debug @place_proxy.inspect

    # update the place proxy from the form params. This merges any changes from the form
    # with the existing place
    @place_proxy.update(params[:place_proxy])
    Rails.logger.debug @place_proxy.inspect

    # set the basic form variables
    set_form_variables
 
    # make sure the place proxy validates
    if @place_proxy.valid?
      # if the place location can be modified we simply create a copy of the place with the same id
      if place.can_alter_location
        new_place = create_place(@place_proxy)
        place.assign_attributes(new_place.get_modifiable_attributes)
      else
        # we can only update the name and home
        place.name = @place_proxy.name
        if @place_proxy.home.to_i == 0
          place.home = false
        else
          @traveler.clear_home
          place.home = true
        end
      end
      Rails.logger.debug place.inspect
      valid = true
    else
      valid = false    
    end
    
    respond_to do |format|
      if valid
        if place.save
          place.reload
          format.html { redirect_to user_places_path(@traveler), :notice => t(:address_book_updated)  }          
          format.json { render json: place, status: :updated, location: place }
        else
          format.html { render action: "index" }
          format.json { render json: @place_proxy.errors, status: :unprocessable_entity }
        end
      else
        format.html { render action: "index" }
        format.json { render json: @place_proxy.errors, status: :unprocessable_entity }
      end    
    end
  end


protected

  def get_indexed_marker_icon(index, type)
    if type == "0"
      return 'startCandidate' + ALPHABET[index]
    elsif type == "1"
      return 'stopCandidate' + ALPHABET[index]
    else
      return 'placeCandidate' + ALPHABET[index]
    end
  end

  def set_form_variables
    @places = @traveler.places
    if @place_proxy.nil?
      @place_proxy = PlaceProxy.new 
    end
    @markers = generate_map_markers(@places)
  end

  # Creates a place proxy from a place. Assumes that if the place is not a POI it
  # came from a raw address
  def create_place_proxy(place)
    
    place_proxy = PlaceProxy.new({:id => place.id, :name => place.name, :raw_address => place.address, :can_alter_location => place.can_alter_location, :lat => place.location.first, :lon => place.location.last, :home => place.home})
    if place.poi
      place_proxy.place_type_id = POI_TYPE
      place_proxy.place_id = place.poi.id
    else
      place_proxy.place_type_id = RAW_ADDRESS_TYPE
    end
    
    return place_proxy
    
  end

  # Creates a place from a proxy.   
  def create_place(place_proxy)

    if place_proxy.place_type_id == POI_TYPE
      # get this POI from the database and add it to the table
      poi = Poi.find(place_proxy.place_id)
      if poi
        place = Place.new
        place.user = @traveler
        place.creator = current_user
        place.poi = poi
        place.name = place_proxy.name      
        place.active = true
        # Check to see if the POI has been reverse geocoded
        if poi.address.blank?
          poi.geocode
        end
      end
    elsif place_proxy.place_type_id == CACHED_ADDRESS_TYPE
      # get the trip place from the database
      trip_place = @traveler.trip_places.find(place_proxy.place_id)
      if trip_place
        place = Place.new
        place.user = @traveler
        place.creator = current_user
        place.raw_address = trip_place.raw_address
        place.name = place_proxy.name 
        place.address1 = trip_place.address1
        place.address2 = trip_place.address2
        place.city = trip_place.city
        place.state = trip_place.state
        place.zip = trip_place.zip
        place.county = trip_place.county
        place.lat = trip_place.lat
        place.lon = trip_place.lon
        place.active = true
      end
    elsif place_proxy.place_type_id == RAW_ADDRESS_TYPE
      # the user entered a raw address and possibly selected an alternate from the list of possible
      # addresses
      addr = get_cached_addresses(CACHED_PLACES_ADDRESSES_KEY)[place_proxy.place_id.to_i]
      place = Place.new
      place.user = @traveler
      place.creator = current_user
      place.name = place_proxy.name 
      place.active = true
      if addr
        place.raw_address = addr[:formatted_address]
        place.address1 = addr[:street_address]
        place.city = addr[:city]
        place.state = addr[:state]
        place.zip = addr[:zip]
        place.county = addr[:county]
        place.lat = addr[:lat]
        place.lon = addr[:lon]
      else
        place.raw_address = place_proxy.raw_address
        place.lat = place_proxy.lat
        place.lon = place_proxy.lon
      end    
    end
    if place_proxy.home.to_i == 0
      place.home = false
    else
      @traveler.clear_home
      place.home = true
    end

    return place    
  end
  
  #
  # generate an array of map markers for use with the leaflet plugin
  #
  def generate_map_markers(places, iconName = nil)

    objs = []
    places.each_with_index do |place, index|
      place_id = 'my_place' + index.to_s
      objs << get_map_marker(place, place_id, (iconName ? iconName : get_indexed_marker_icon(index, "0")))
    end
    return objs.to_json
  end

end