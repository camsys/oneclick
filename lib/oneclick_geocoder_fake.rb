
#
# Centralizes all the geocoding logic we need
class OneclickGeocoderFake

  attr_accessor :raw_address, :results, :sensor, :bounds, :components, :errors

  INCLUDED_TYPES = %w{
    airport 
    establishment
    intersection 
    natural_feature 
    park 
    point_of_interest
    premise
    route 
    street_address 
  }
  
  def initialize(attrs = {})
    @results = (1..20).collect do |i|
      {
        name: "bar #{i}",
        lat: 0.0,
        lon: 0.0,
          :formatted_address => 'A really long address for the formatted address field',
          :street_address => 'and a pretty long one for the street address field as well',
      }
    end
    @errors = []
  end

  def has_errors
    return @errors.count > 1
  end 
  
  def reverse_geocode(lat, lon)
    raise "Not implemented"
    [@errors.empty?, @errors, @results]
  end

  def geocode(raw_address)
    [@errors.empty?, @errors, @results]
  end
  
  protected
  
  
  # Google puts the country designator into the formatted address. We don't want this so we chomp the
  # end of the address string if the designator is there
  def sanitize_formatted_address(addr)
    if addr.include?(", USA")
      return addr[0..-6]
    else
      return addr
    end    
  end
  
  # Filters addresses returned by Google to only those we want to consider
  def is_valid(addr_types)
    addr_types.each do |addr_type|
      if INCLUDED_TYPES.include?(addr_type)
        return true
      end
    end
    return false;
  end
  
  def reset
    @results = []
    @errors = []
  end

end