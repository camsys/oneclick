class PlaceProxy

  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend  ActiveModel::Naming

  attr_accessor :raw_address, :name
    
  validates :raw_address, :presence => true
  validates :name, :presence => true
  
  def initialize(attrs = {})
    attrs.each do |k, v|
      self.send "#{k}=", v
    end
  end

  # Override the save method to prevent exceptions.
  def save(validate = true)
    validate ? valid? : true
  end
  
  def persisted?
    false
  end

  def geocode
    alternatives = []
    if raw_address.blank?
      return alternatives
    end
    
    results = Geocoder.search(self.raw_address, sensor: false, components: Rails.application.config.geocoder_components, bounds: Rails.application.config.geocoder_bounds)
    results.each do |alt|
      alternatives << {
        :formatted_address => alt.formatted_address,
        :street_address => alt.street_address,
        :city => alt.city,
        :state => alt.state,
        :zip => alt.postal_code,
        :lat => alt.coordinates.first,
        :lon => alt.coordinates.last
      }
    end
    return alternatives
  end
             
end