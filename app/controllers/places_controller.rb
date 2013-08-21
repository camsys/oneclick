class PlacesController < TravelerAwareController
  
  # include the Leaflet helper into the controller and view
  helper LeafletHelper
  
  # set the @place variable before any actions are invoked
  before_filter :get_place, :only => [:show, :destroy, :edit]
  
  def index
    @places = @traveler.places  
    @place_proxy = PlaceProxy.new
    @alternative_places = []
    @markers = generate_map_markers(@places)
  end
  
  def show

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @places }
    end
    
  end
  
  # Called when a user has selected a place
  def add
    
    # We need to call this as its not called automatically for this method
    get_traveler
    
    place = Place.new
    place.user = @traveler
    place.creator = current_user
    place.name = params[:name]
    place.raw_address = params[:address]
    place.lat = params[:lat]
    place.lon = params[:lon]
    if place.save
      flash[:notice] = "#{place.name} has been added to your address book."            
    else
      flash[:alert] = "An error occurred adding #{place.name} to your address book."      
    end
    redirect_to user_places_path(@traveler)
  end
  
  def create
    place_proxy = PlaceProxy.new(params[:place_proxy])
    
    # attempt to geocode this place
    @alternative_places = place_proxy.geocode
    respond_to do |format|
      format.js {render "show_geocoding_results"}
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