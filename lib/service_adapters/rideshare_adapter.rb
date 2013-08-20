module ServiceAdapters
  module RideshareAdapter

    def service_url
      'https://www.mygacommuteoptions.com/rp2/trip/search'
    end

    def create_rideshare_query from, to, trip_datetime
      from_geo = Geocoder.transpose(YAML.load(from.geocoding_raw))
      to_geo = Geocoder.transpose(YAML.load(to.geocoding_raw))
      query = {}
      query['date'] = trip_datetime.strftime("%m/%d/%Y %I:%M %p") # TODO format 8/21/2013 8:00 AM
      [
        ['dest', to_geo, to],
        ['orig', from_geo, from],
        ].each do |p, s1, s2|
          query["#{p}.city"] = s1['locality']['short_name'] rescue ''
          query["#{p}.country"] = s1['country']['short_name'] rescue ''
          query["#{p}.county"] = s1['administrative_area_level_2']['short_name'] rescue ''
          query["#{p}.geocodeType"] = 'Address'
          query["#{p}.latLon.x"] = s2.lon
          query["#{p}.latLon.y"] = s2.lat
          # query["#{p}.line2"] = to.address2
          query["#{p}.postalCode"] = s1['postal_code']['short_name'] rescue ''
          query["#{p}.state"] = s1['administrative_area_level_1']['short_name'] rescue ''
          query["#{p}.street"] = s1['street_number']['short_name'] + ' ' + s1['route']['short_name'] rescue s1['premise']['short_name'] + ' ' + s1['route']['short_name'] rescue
            s1['route']['short_name'] rescue s1['premise']['short_name'] rescue ''
        # query['dest.suburb'] = 
      end
      query['search'] = 'search'
      query['window'] = 3
      query['windowOption'] = 'hours'
      query
    end

  end
end
