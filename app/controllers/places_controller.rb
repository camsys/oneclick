class PlacesController < TravelerAwareController

  # include the Leaflet helper into the controller and view
  helper LeafletHelper

  CACHED_ADDRESSES_SESSION_KEY = 'places_address_cache'

  # set the @traveler variable for actions that are not supported by teh super class controller
  before_filter :get_traveler, :only => [:index, :add_place, :add_poi, :create, :destroy, :change]
  # set the @place variable before any actions are invoked
  before_filter :get_place, :only => [:show, :destroy, :edit]
  def index
    @places = @traveler.places
    @place_proxy = PlaceProxy.new
    @alternative_places = []
    @markers = generate_map_markers(@places)
  end

  # called when a user adds a new poi
  def add_poi

    poi_proxy = PoiProxy.new(params[:poi_proxy])
    if poi_proxy.valid?
      poi = Poi.find(poi_proxy.poi_id)
  
      place = Place.new
      place.user = @traveler
      place.creator = current_user
      place.poi = poi
      place.name = poi.name
  
      place.active = true
      if place.save
        flash[:notice] = "#{place.name} has been added to your address book."
      else
        flash[:alert] = "An error occurred adding #{place.name} to your address book."
      end
    else
      flash[:alert] = "You must select a point of interest."
    end
    redirect_to user_places_path(@traveler)

  end

  # Called when a user has selected a place
  def add_place

    addresses = session[CACHED_ADDRESSES_SESSION_KEY]
    if addresses.nil?
      # we cant get the addresses from the session so they might have posted this address using
      # some other service.
      flash[:alert] = "An error occurred adding #{params[:address]} to your address book."
      redirect_to user_places_path(@traveler)
      return
    end
    # get the index of the cached address they selected
    id = params[:ref].to_i
    address = addresses[id]
    # create the place from this address
    place = Place.new
    place.user = @traveler
    place.creator = current_user
    place.name = address[:name]
    place.raw_address = address[:street_address]
    place.address1 = address[:name]
    place.city = address[:city]
    place.state = address[:state]
    place.zip = address[:zip]
    place.lat = address[:lat]
    place.lon = address[:lon]
    place.active = true
    if place.save
      flash[:notice] = "#{place.name} has been added to your address book."
    else
      flash[:alert] = "An error occurred adding #{place.name} to your address book."
    end
    redirect_to user_places_path(@traveler)
  end

  # handles the user changing a place name from the form
  def change
    place = @traveler.places.find(params[:place][:id])
    if place
      place.name = params[:place][:name]
      if place.save
        flash[:notice] = "#{place.name} has been changed in your address book."
      else
        flash[:alert] = "An error occurred while updating your address book."
      end
      redirect_to user_places_path(@traveler)
    return
    else
      redirect_to error_404_path
    end

  end

  # not really a destroy -- just hides the place by setting active = false
  def destroy
    place = @traveler.places.find(params[:id])
    if place
      place.active = false
      if place.save
        flash[:notice] = "#{place.name} has been removed from your address book."
      else
        flash[:alert] = "An error occurred adding #{place.name} to your address book."
      end
      redirect_to user_places_path(@traveler)
    return
    else
      redirect_to error_404_path
    end

  end

  # the user has entered an address and we need to validate it
  # by geocoding it. The results are returned to the view but are
  # also cached so we don't need to re-geocode if they decide to use
  # one
  def create

    place_proxy = PlaceProxy.new(params[:place_proxy])

    # attempt to geocode this place
    geocoder = OneclickGeocoder.new
    geocoder.geocode(place_proxy.raw_address)
    
    # cache the results in the session
    if geocoder.has_errors
      session[CACHED_ADDRESSES_SESSION_KEY] = []
      @alternative_places = []
    else
      session[CACHED_ADDRESSES_SESSION_KEY] = geocoder.results
      @alternative_places = geocoder.results
    end
    respond_to do |format|
      format.js {render "show_geocoding_results"}
    end

  end

  # Search for POIs based on a partial POI name
  def search

    query = params[:query]
    poi_type_id = params[:poi_type_id]
    if poi_type_id.blank?
      pois = Poi.where("name LIKE ?", "%" + query + "%").limit(50)
    else
      pois = Poi.where("poi_type_id = ? AND name LIKE ?", poi_type_id, "%" + query + "%")
    end
    matches = []
    pois.each do |poi|
      matches << {
        "name" => poi.name,
        "id" => poi.id,
        "lat" => poi.lat,
        "lon" => poi.lon,
        "address" => poi.address
      }
    end
    respond_to do |format|
      format.js { render :json => matches.to_json }
    end
  end

  protected

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
    places.each do |place|
      objs << get_map_marker(place)
    end
    return objs.to_json
  end

  # create an place map marker
  def get_map_marker(place)
    location = place.location
    {
      "id" => place.id,
      "lat" => location.first,
      "lng" => location.last,
      "name" => place.name,
      "iconClass" => 'greenIcon',
      "title" => place.name,
      "description" => render_to_string(:partial => "/places/place_popup", :locals => { :place => place })
    }
  end

end