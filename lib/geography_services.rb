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

  def global_boundary
    if global_boundary_exists?
      return OneclickConfiguration.find_by(code: 'global_boundary').value
    else
      return nil
    end
  end

  def global_boundary_as_geojson
    mercator_factory = RGeo::Geographic.simple_mercator_factory
    #geojson_factory = RGeo::GeoJSON::EntityFactory.instance

    #feature = geojson_factory.feature(@object.position, nil, { desc: @object.description})
    boundary_shape = mercator_factory.parse_wkt(global_boundary)

    RGeo::GeoJSON.encode boundary_shape
  end

  def county_from_google_place place
    address_components = place[:address_components]
    if address_components
      address_components.each do |component|
        if 'administrative_area_level_2'.in? component[:types]
          return component[:long_name].sub(' County', '')
        end
      end
    end
    return nil
  end

end