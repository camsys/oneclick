class GeocodedAddress < ActiveRecord::Base
  include InterestingAttributes
  
  self.abstract_class = true  
  
  # # attr_accessible :address1, :address2, :city, :state, :zip
  # # attr_accessible :lat, :lon
  # # attr_accessible :county

  def get_zipcode
    return zip
  end
  
  def get_location
    return [lat, lon]
  end

  def get_county_name
    return county
  end

  def get_city
    return city
  end

  def get_address(format = 1)
    case format
    when 2
      # a1[, a2] city, state zip
      [[[address1, address2].reject{|a| a.blank?}.join(', '),
      city].join(' '),
      [state, zip].join(' ')].reject{|s| s.blank?}.join(', ')      
    else
      # when 1
      # a1, [a2, ]city, state zip
      [[address1, address2].reject{|a| a.blank?}.join(', '),
      city,
       [state, zip].join(' ')].reject{|s| s.blank?}.join(', ')
    end
  end

  def within_callnride?
    begin
      factory = RGeo::Geographic.simple_mercator_factory
      point = factory.point(self.lon.to_f, self.lat.to_f)
      Oneclick::Application.config.callnride_boundary.contains? point
    rescue
      return false
    end
  end
  
end
