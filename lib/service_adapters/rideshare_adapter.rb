module ServiceAdapters
  module RideshareAdapter

    def service_url
      'https://www.mygacommuteoptions.com/rp2/trip/search'
    end

    def create_rideshare_query from, to, trip_datetime
      query = {}
      query['date'] = trip_datetime.strftime("%m/%d/%Y %-I:%M %p") # TODO format 8/21/2013 8:00 AM
      to = find_place(to)
      from = find_place(from)
      [
        ['dest', to],
        ['orig', from],
        ].each do |p, s1|
          # methods = (s1.public_methods - Object.public_methods).reject{|m| m =~ /=/}
          # methods.each do |m|
          #   Rails.logger.debug "#{m} #{s1.send(m.to_sym)}" rescue "#{m} failed"
          # end
          query["#{p}.city"] = s1[:city]
          query["#{p}.country"] = 'US'
          query["#{p}.county"] = s1[:county]
          query["#{p}.geocodeType"] = 'Address'
          query["#{p}.latLon.x"] = s1[:lon]
          query["#{p}.latLon.y"] = s1[:lat]
          # query["#{p}.line2"] = to.address2
          query["#{p}.postalCode"] = s1[:zip]
          query["#{p}.state"] = s1[:state]
          query["#{p}.street"] = s1[:address1]
      end
      query['search'] = 'search'
      query['window'] = 3
      query['windowOption'] = 'hours'
      query
    end

    # TODO This possibly go with places, instead of here.  Return a usable place
    # (e.g. either this, or the named place, or the POI)
    def find_place place
      if place.place
        return place.place
      elsif place.poi
        return place.poi
      end
      place
    end

  end
end
