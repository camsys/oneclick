class FareZone < ActiveRecord::Base
  belongs_to :service

  ZONE_ID_COLUMN = 'ZONE';

  def self.parse_shapefile(shapefile_path, service)
    unless shapefile_path.nil? || !service

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
                break if !shape.attributes.keys.index(ZONE_ID_COLUMN)
                zone_id = shape.attributes[ZONE_ID_COLUMN]
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

end
