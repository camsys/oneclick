class FareZone < ActiveRecord::Base
  belongs_to :service

  SRID = 0 # Should be 4326, but need to do database change first

  def self.parse_shapefile(zone_id_column, shapefile_path, service)
    unless zone_id_column.blank? || shapefile_path.nil? || !service

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
                key_index = shape.attributes.keys.map(&:downcase).index(zone_id_column.downcase)
                break if !key_index

                zone_id = shape.attributes[shape.attributes.keys[key_index]]
                if  !shape.geometry.nil? and shape.geometry.geometry_type.to_s.downcase.include?('polygon') #only return first polygon
                  FareZone.create(
                    geom: shape.geometry,
                    zone_id: zone_id,
                    service: service
                  )
                end
              end
            end
          end
        end
      end

    end
  end

  def self.identify(lat, lng)
    return nil unless lat && lng 

    pt = RGeo::Geographic.spherical_factory(:srid => SRID).point(lng, lat)

    zone = where("ST_Contains(geom, ?)", pt).first

    zone.id if zone
  end

end
