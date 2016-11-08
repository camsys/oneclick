class TaxiService < Service

  def is_valid_for_trip_area(from, to)

    #taken from def eligible_by_location(trip_part, itineraries)
    #some day we may want to pass the whole object around and not just from/to

    factory = RGeo::Geographic.simple_mercator_factory


    origin_point = factory.point(from.lon.to_f, from.lat.to_f)
    destination_point = factory.point(to.lon.to_f,to.lat.to_f)

    origin_county = from.county
    destination_county = to.county

    service = self

    #Match Endpoint County Names
    unless service.county_endpoint_array.blank?
     return false unless origin_county.in? service.county_endpoint_array or destination_county.in? service.county_endpoint_array
    end

    #Match Coverage County Names
    unless service.county_coverage_array.blank?
     return false unless origin_county.in? service.county_coverage_array and destination_county.in? service.county_coverage_array
    end

    #Match Endpoint Area
    unless service.endpoint_area_geom.nil?
     return false unless service.endpoint_area_geom.geom.contains? origin_point or service.endpoint_area_geom.geom.contains? destination_point
    end

    #Match Coverage Area
    unless service.coverage_area_geom.nil?
     return false unless service.coverage_area_geom.geom.contains? origin_point and service.coverage_area_geom.geom.contains? destination_point
    end

    # Match (New) Secondary Coverage Area
    # This is not necessary given current UI -- taxis only get primary coverage area -- but keeping in place just in case.
    unless service.secondary_coverage.nil?
      return false unless service.secondary_coverage.geom.contains? origin_point or service.secondary_coverage.geom.contains? destination_point
    end

    # Match (New) Primary Coverage Area
    unless service.primary_coverage.nil?
      return false unless service.primary_coverage.geom.contains? origin_point and service.primary_coverage.geom.contains? destination_point
    end

    Rails.logger.info "eligible_by_location for service #{service.name rescue nil}"

    return true

  end

end
