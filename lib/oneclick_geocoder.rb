#
# Centralizes all the geocoding logic we need
class OneclickGeocoder

  attr_accessor :raw_address, :results, :sensor, :bounds, :components, :errors
  
  def initialize(attrs = {})
    # reset the current state
    reset
    @sensor = false
    @components = Rails.application.config.geocoder_components
    @bounds = Rails.application.config.geocoder_bounds
    attrs.each do |k, v|
      self.send "#{k}=", v
    end
  end
    
  def has_errors
    return @errors.count > 1
  end 
  
  def reverse_geocode(lat, lon)
    # reset the current state
    reset
    @raw_address = [lat, lon]
    begin
      res = Geocoder.search(@raw_address)
      process_results(res)
    rescue Exception => e
      @errors << e.message
    end
  end

  def geocode(raw_address)
    # reset the current state
    reset
    @raw_address = raw_address
    if raw_address.blank?
      return @results
    end
    #TODO add error management here
    begin
      res = Geocoder.search(@raw_address, sensor: @sensor, components: @components, bounds: @bounds)
      process_results(res)
    rescue Exception => e
      @errors << e.message
    end
  end
  
protected
  
  def process_results(res)
    i = 0
    res.each do |alt|
      if is_valid(alt.types)
        @results << {
          :id => i,
          :name => alt.formatted_address.split(",")[0],
          :formatted_address => alt.formatted_address,
          :street_address => alt.address,
          :city => alt.city,
          :state => alt.state_code,
          :zip => alt.postal_code,
          :lat => alt.latitude,
          :lon => alt.longitude
        }
        i += 1
      end
    end    
  end    

  # Filters addresses returned by Google to only those we want to consider
  def is_valid(addr_types)
    addr_types.each do |addr_type|
      if ['street_address', 'route', 'intersection', 'natural_feature', 'airport', 'park', 'point_of_interest'].include?(addr_type)
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