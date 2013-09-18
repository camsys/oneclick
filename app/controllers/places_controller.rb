class PlacesController < PlaceSearchingController

  # include the Leaflet helper into the controller and view
  helper LeafletHelper
  
  # set the @traveler variable for actions that are not supported by teh super class controller
  before_filter :get_traveler, :only => [:index, :add_place, :add_poi, :create, :destroy, :change]
  # set the @place variable before any actions are invoked
  before_filter :get_place, :only => [:show, :destroy, :edit]
  
  def index
    
    # set the basic form variables
    set_form_variables

  end

  # handles the user changing a place name from the form
  def change
    place = @traveler.places.find(params[:place][:id])
    if place
      place.name = params[:place][:name]
      if place.save
        flash[:notice] = t(:address_book_updated)
      else
        flash[:alert] = t(:error_updating_addresses)
      end
    else
      flash[:alert] = t(:error_updating_addresses)
    end

    # set the basic form variables
    set_form_variables

    respond_to do |format|
      format.js {render "update_form_and_map"}
    end
    
  end

  # not really a destroy -- just hides the place by setting active = false
  def destroy
    place = @traveler.places.find(params[:id])
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
      format.js {render "update_form_and_map"}
    end
  end

  def create

    # inflate a place proxy object from the form params
    @place_proxy = PlaceProxy.new(params[:place_proxy])
       
    if @place_proxy.valid?
      @place = create_place(@place_proxy)
    end

    # set the basic form variables
    set_form_variables

    respond_to do |format|
      if @place
        if @place.save
          # we are done with this input so clear everything out
          @place_proxy = nil
          set_form_variables
          format.html { render action: "index", :notice => "Event was successfully created." }
          format.json { render :json => @place, :status => :created, :location => @place }
        else
          format.html { render action: "index" }
          format.json { render json: @place_proxy.errors, status: :unprocessable_entity }
        end
      else
        format.html { render action: "index", flash[:alert] => "One or more addresses need to be fixed." }
      end
    end
  end


protected

  def set_form_variables
    
    @places = @traveler.places
    if @place_proxy.nil?
      @place_proxy = PlaceProxy.new 
    end
    @markers = generate_map_markers(@places)
    
  end

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
        place.lat = trip_place.lat
        place.lon = trip_place.lon
        place.active = true
      end
    elsif place_proxy.place_type_id == RAW_ADDRESS_TYPE
      # the user entered a raw address and possibly selected an alternate from the list of possible
      # addresses
      addr = get_cached_addresses(CACHED_PLACES_ADDRESSES_KEY)[place_proxy.place_id.to_i]
      if addr
        place = Place.new
        place.user = @traveler
        place.creator = current_user
        place.raw_address = addr[:formatted_address]
        place.name = place_proxy.name 
        place.lat = addr[:lat]
        place.lon = addr[:lon]
        place.active = true
      end    
    end
    return place    
  end
  
  def get_place
    if user_signed_in?
      # limit places to those owned by the user unless an admin
      if current_user.has_role? :admin
        @place = Place.find(params[:id])
      else
        @place = @traveler.places.find(params[:id])
      end
    end
  end

  #
  # generate an array of map markers for use with the leaflet plugin
  #
  def generate_map_markers(places)

    objs = []
    places.each_with_index do |place, index|
      place_id = 'my_place' + index.to_s
      objs << get_map_marker(place, place_id, get_indexed_marker_icon(index, "0"))
    end
    return objs.to_json
  end

end