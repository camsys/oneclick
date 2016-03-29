namespace :oneclick do

  desc "Load new Landmarks"
  task :load_new_landmarks => :environment do

    require 'open-uri'

    begin
      lm = Oneclick::Application.config.landmarks_file
    rescue
      puts 'No Landmarks File Specified.  Need to specify Oneclick::Application.config.landmarks_file'
      next #Exit the rake task if not file is specified
    end

    landmarks_file = open(lm)

    #Check to see if this file is newer than the last time Pois were udpated
    p = Poi.first
    if p
      if p.updated_at > landmarks_file.last_modified
        puts lm.to_s + ' is an old file.'
        puts 'Landmarks were last updated at: ' + p.updated_at.to_s
        puts lm.to_s + ' was last update at ' + landmarks_file.last_modified.to_s
        next
      end
    end

    #Pull out the Poi/Landmark info for each line and try to find a google place_id if it exists.
    #Google place IDs are used for RTD
    #RTD has given us a set of Landmarks that should override Google
    failed = false
    Poi.update_all(old: true)
    line = 2 #Line 1 is the header, start with line 2 in the count
    og = OneclickGeocoder.new
    CSV.foreach(landmarks_file, {:col_sep => ",", :headers => true}) do |row|
      begin
        poi_type_name = row[8]
        if poi_type_name.blank?
          poi_type_name = 'Unknown'
        end
        poi_type = PoiType.find_by_name(poi_type_name)
        if poi_type.nil?
          #Rails.logger.info "Adding new poi type #{poi_type_name}"
          poi_type = PoiType.create({:name => poi_type_name, :active => true})
        end
        poi_name = row[1]
        poi_city = row[3]
        #If we have already created this POI, don't create it again.
        if poi_name
          p = Poi.create!({
                              poi_type: poi_type,
              lon: row[13],
              lat: row[14],
              name: poi_name,
              address1: row[2],
              city: poi_city,
              state: "CO",
              zip: row[4],
              old: false,
          })

          #Check to see if a Google Place exits and get the Google Place ID
          begin
            geocoded = og.geocode(p.address1.to_s + ' ' + p.city.to_s + ', ' + p.state.to_s + ' ' + p.zip.to_s)
            if geocoded[0] and geocoded[2].count > 0 #If there are no errors?
              place_id = geocoded[2].first[:place_id]
              p.google_place_id = place_id
              p.save
            else #Try Reverse Geocoding
              reverse_geocoded = og.reverse_geocode(p.lat, p.lon)
              if reverse_geocoded[0] and reverse_geocoded[2].count > 0 #No errors?
                place_id = reverse_geocoded[2].first[:place_id]
                p.google_place_id = place_id
                p.save
              end
            end
          rescue
            puts 'Error Geocoding ' + poi_name.to_s + ' on row ' + line.to_s + '. Continuing . . . '
          end

        end
      rescue
        #Found an error, back out all changes and restore previous POIs
        puts 'Error found on line: ' + line.to_s
        puts row
        puts 'All changes have been rolled-back and previous Landmarks have been restored'
        Poi.is_new.delete_all
        Poi.is_old.update_all(old: false)
        failed = true
        break
      end
      line += 1
    end

    unless failed
      puts 'Done: Loaded ' + (line - 2).to_s + ' new Landmarks'
      Poi.is_old.delete_all
      Poi.update_all(old: false)
    end

  end
end