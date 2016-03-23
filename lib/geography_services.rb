class GeographyServices

  # Check to see if a global boundary exists?
  def global_boundary_exists?
    return OneclickConfiguration.where(code: 'global_boundary').exists?
  end

  # Check to see if a point falls within the global boundary for this system
  def within_global_boundary?(lat,lng)
    boundary = OneclickConfiguration.find_by(code: 'global_boundary')

    if boundary.nil?
      return true
    end

    mercator_factory = RGeo::Geographic.simple_mercator_factory
    test_point = mercator_factory.point(lng, lat)
    boundary_shape = mercator_factory.parse_wkt(boundary.value)
    return boundary_shape.contains? test_point
  end

end