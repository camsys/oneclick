class TaxiService < Service

  def is_valid_for_trip_area(from, to)

   #taken from def eligible_by_location(trip_part, itineraries)
   #some day we may want to pass the whole object around and not just from/to

   mercator_factory = RGeo::Geographic.simple_mercator_factory

   service = self

   Rails.logger.info "eligible_by_location for service #{service.name rescue nil}"

   origin_point = mercator_factory.point(from[1], from[0])
   destination_point = mercator_factory.point(to[1], to[0])

   unless service.endpoint_area_geom.nil?
      return false unless service.endpoint_area_geom.geom.contains? origin_point
   end

   unless service.coverage_area_geom.nil?
     return false unless service.coverage_area_geom.geom.contains? origin_point and service.coverage_area_geom.geom.contains? destination_point
   end

   return true

  end

end