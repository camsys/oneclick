module Geocoder
  def transpose result
    result['data']['address_components'].inject({}) do |m, a|
      m[a['types'].reject{|ty| ty == 'political'}.first] = a
      m
    end
  end
end