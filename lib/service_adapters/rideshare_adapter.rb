module ServiceAdapters
  module RideshareAdapter

    def service_url
      'https://www.mygacommuteoptions.com/rp2/trip/search'
    end

    def create_rideshare_query from, to, trip_datetime
      query = {}
      query['date'] = trip_datetime.strftime("%m/%d/%Y %-I:%M %p") # TODO format 8/21/2013 8:00 AM
      [
        ['dest', to.raw],
        ['orig', from.raw],
        ].each do |p, s1|
          # methods = (s1.public_methods - Object.public_methods).reject{|m| m =~ /=/}
          # methods.each do |m|
          #   Rails.logger.info "#{m} #{s1.send(m.to_sym)}" rescue "#{m} failed"
          # end
          query["#{p}.city"] = s1.city rescue ''
          query["#{p}.country"] = s1.country_code rescue ''
          query["#{p}.county"] = s1.sub_state rescue ''
          query["#{p}.geocodeType"] = 'Address'
          query["#{p}.latLon.x"] = s1.longitude rescue ''
          query["#{p}.latLon.y"] = s1.latitude rescue ''
          # query["#{p}.line2"] = to.address2
          query["#{p}.postalCode"] = s1.postal_code rescue ''
          query["#{p}.state"] = s1.state_code rescue ''
          query["#{p}.street"] = s1.street_address rescue ''
      end
      query['search'] = 'search'
      query['window'] = 3
      query['windowOption'] = 'hours'
      query
    end

  end
end
