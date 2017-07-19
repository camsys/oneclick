class Place < GeocodedAddress

  # associations
  belongs_to  :user
  belongs_to  :creator, :class_name => "User", :foreign_key => "creator_id"
  belongs_to  :poi       # optional
  has_many    :trip_places # optional
  serialize :types

  # attr_protected :id, :user_id, :created_at, :updated_at
  # attr_accessible :name, :raw_address
  # attr_accessible :creator_id, :poi_id, :active, :home, :lat, :lon
  
  scope :active, -> {where("places.active = true")}
  default_scope {order("name")}
  
  # Returns true if the user can delete this place from their My Places
  # false otherwise
  def can_delete
    # check all the trip places associated with this place
    trip_places.each do |tp|
      # if any trip is in the future it cant be removed
      if tp.trip.in_the_future
        return false
      end
    end
    # looks like they are all in the past
    return true
  end
  
  # Returns true if the user can alter the address or POI reference for this place. false otherwise
  def can_alter_location
    # check all the trip places associated with this place
    trip_places.each do |trip_place|
      if trip_place.trip
        # check all the planned trips associated with each trip_place trip
        trip_place.trip.trip_parts.each do |trip_part|
          # if a trip part has an itinerary we can't mutate it
          if trip_part.itineraries.count > 0
            return false
          end
        end
      end
    end
    # looks like they are all ok
    return true
  end
  
  # Returns a hash of attributes that are modifiable
  def get_modifiable_attributes
    return attributes.except(*Place.protected_attributes)
  end
  
  # Use this as the main method for getting a place's location
  def location
    return poi.location unless poi.nil?
    return get_location
  end

  # Use this as the main method for getting a place's zipcode
  def zipcode
    return poi.zipcode unless poi.nil?
    return get_zipcode
  end
   
  def to_s
    return name
  end
  
  # convienience method for geocoding places
  def geocode
    geocoder = OneclickGeocoder.new
    geocoder.geocode(raw_address)
    res = geocoder.results
    if res.first
      address = res.first
      self.name = address[:name] unless self.name
      self.address1 = address[:name]
      self.city = address[:city]
      self.state = address[:state]
      self.zip = address[:zip]
      self.lat = address[:lat]
      self.lon = address[:lon]
      self.county = address[:county]
      self.active = true      
    end  
  end
  
  def address
    if poi
      addr = poi.address
    else
      addr = get_address
      if addr.blank?
        addr = raw_address   
      end
    end
    return addr
  end
 
  def county_name
    if poi
      return poi.county_name
    else
      return get_county_name
    end
  end

  def type_name
    'PLACES_TYPE'
  end

  def build_place_details_hash
    #Based on Google Place Details
    {
        address_components: self.address_components,

        formatted_address: self.raw_address || self.build_formatted_address,
        place_id: self.google_place_id,
        geometry: {
        location: {
        lat: self.lat,
        lng: self.lon,
      }
    },
        id: self.id,
        name: self.name,
        scope: "user",
        stop_code: self.stop_code,
        types: self.types
    }
  end

  def build_formatted_address
    address = ""
    if self.address1
      address += self.address1 + ', '
    end

    if self.city
      address += self.city + ', '
    end

    if self.state
      address += self.state + '  '
    end

    if self.zip
      address += self.zip + '  '
    end

    return address.chop.chop

  end

  def address_components
    address_components = []

    #street_number
    if self.street_number
      address_components << {long_name: self.street_number, short_name: self.street_number, types: ['street_number']}
    end

    #Route
    if self.route
      address_components << {long_name: self.route, short_name: self.route, types: ['route']}
    end

    #Street Address
    if self.address1
      address_components << {long_name: self.address1, short_name: self.address1, types: ['street_address']}
    end

    #City
    if self.city
      address_components << {long_name: self.city, short_name: self.city, types: ["locality", "political"]}
    end

    #State
    if self.state
      address_components << {long_name: self.zip, short_name: self.zip, types: ["postal_code"]}
    end

    #Zip
    if self.zip
      address_components << {long_name: self.state, short_name: self.state, types: ["administrative_area_level_1","political"]}
    end

    return address_components

  end

end
