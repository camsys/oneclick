class GeographyServices
  require 'zip'

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

  def store_callnride_boundary(shapefile_path)
    shapes = []
    unless shapefile_path.nil?
      begin
        Zip::File.open(shapefile_path) do |zip_file|
          zip_shp = zip_file.glob('**/*.shp').first
          unless zip_shp.nil?
            zip_shp_paths = zip_shp.name.split('/')
            file_name = zip_shp_paths[zip_shp_paths.length - 1].sub '.shp', ''
            shp_name = nil
            Dir.mktmpdir do |dir|
              shp_name = "#{dir}/" + file_name + '.shp'
              zip_file.each do |entry|
                entry_names = entry.name.split('/')
                entry_name = entry_names[entry_names.length - 1]
                if entry_name.include?(file_name)
                  entry.extract("#{dir}/" + entry_name)
                end
              end
              RGeo::Shapefile::Reader.open(shp_name, { :assume_inner_follows_outer => true }) do |shapefile|
                shapefile.each do |shape|
                  if not shape.geometry.nil?
                    shapes << {name: shape.attributes['NAME'], geometry: shape.geometry}
                  end
                end
              end
            end
          end
        end

      oc = OneclickConfiguration.where(code: "callnride_boundary").first_or_initialize
      oc.value = shapes
      oc.save

      rescue Exception => msg
        Rails.logger.info 'shapefile parse error'
        Rails.logger.info msg
        return msg
      end
    end

    return "Call-N-Ride Boundary Updated"
  end


end