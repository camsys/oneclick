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
    poi_type = PoiType.where(name: 'LANDMARK', active: true).first_or_create
    p = Poi.where(poi_type: poi_type).first
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
    Poi.where(poi_type: poi_type).update_all(old: true)
    line = 2 #Line 1 is the header, start with line 2 in the count
    og = OneclickGeocoder.new
    CSV.foreach(landmarks_file, {:col_sep => ",", :headers => true}) do |row|
      begin
        poi_type_name = row[8]
        if poi_type_name.blank?
          poi_type_name = 'Unknown'
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

            #First try geocoding without the name/city/state/zip and NOT with the address
            # This will let us identify Google Places instaed of addresses
            geocoded = og.geocode(p.name.to_s + ', ' + p.city.to_s + ', ' + p.state.to_s + ' ' + p.zip.to_s)
            if geocoded[0] and geocoded[2].count > 0 #If there are no errors?
              place_id = geocoded[2].first[:place_id]
              p.google_place_id = place_id
              p.save
            else

              #Second try throwing in the address
              geocoded = og.geocode(p.name.to_s + ', ' + p.address1.to_s + ' ' + p.city.to_s + ', ' + p.state.to_s + ' ' + p.zip.to_s)
              if geocoded[0] and geocoded[2].count > 0 #If there are no errors?
                place_id = geocoded[2].first[:place_id]
                p.google_place_id = place_id
                p.save
              else

               #If the other two attempts fail, just use the Lat,Lng
               reverse_geocoded = og.reverse_geocode(p.lat, p.lon)
               if reverse_geocoded[0] and reverse_geocoded[2].count > 0 #No errors?
                 place_id = reverse_geocoded[2].first[:place_id]
                 p.google_place_id = place_id
                 p.save
               end
              end
            end
          rescue
            puts 'Error Geocoding ' + poi_name.to_s + ' on row ' + line.to_s + '. Continuing . . . '
          end

        end
      rescue
        #Found an error, back out all changes and restore previous POIs
        error_string = 'Error found on line: ' + line.to_s
        row_string = row
        puts error_string
        puts row
        puts 'All changes have been rolled-back and previous Landmarks have been restored'
        Poi.where(poi_type: poi_type).is_new.delete_all
        Poi.where(poi_type: poi_type).is_old.update_all(old: false)
        failed = true

        #Email alert of failure
        UserMailer.landmarks_failed_email(Oneclick::Application.config.support_emails.split(','), error_string, row_string).deliver!
        break
      end
      line += 1
    end

    unless failed
      puts 'Done: Loaded ' + (line - 2).to_s + ' new Landmarks'
      Poi.where(poi_type: poi_type).is_old.delete_all
      Poi.where(poi_type: poi_type).update_all(old: false)

      non_geocoded_pois = Poi.where(poi_type: poi_type, google_place_id: nil)

      #Alert that the new landmarks file was successfuly updated
      UserMailer.landmarks_succeeded_email(Oneclick::Application.config.support_emails.split(','), non_geocoded_pois).deliver!
    end

  end

  desc "Load new Stops"
  task :load_new_stops => :environment do

    tp = TripPlanner.new
    poi_type = PoiType.where(name: 'STOP', active: true).first_or_create
    p = Poi.where(poi_type: poi_type).first
    if p
      if p.updated_at > tp.last_built
        puts  'OpenTripPlanner graph has not been updated since last loading Stops.'
        puts 'Stops were last updated at: ' + p.updated_at.to_s
        puts Oneclick::Application.config.open_trip_planner + ' graph was last update at ' + tp.last_built.to_s
        next
      end
    end

    Poi.where(poi_type: poi_type).update_all(old: true)
    failed = false

    stops = tp.get_stops
    stops.each do |stop|
      begin
        #each stop id comes in the form "agency_id:stop_id", we only want the stop_id
        stop_code = stop['id'].split(':').last  #TODO: The GTFS doesn't have stop_codes, using id for now.
        name = stop['name']
        lat = stop['lat']
        lon = stop['lon']

        p = Poi.create!({
            poi_type: poi_type,
            stop_code: stop_code,
            lon: lon,
            lat: lat,
            name: name,
            old: false,
        })
      rescue
        Poi.where(poi_type: poi_type).is_new.delete_all
        Poi.where(poi_type: poi_type).is_old.update_all(old: false)
        failed = true
        UserMailer.stops_failed_email(Oneclick::Application.config.support_emails.split(',')).deliver!
        puts 'Error encountered loading stops from OpenTripPlanner at ' + Oneclick::Application.config.open_trip_planner.to_s
        break
      end
    end

    unless failed
      Poi.where(poi_type: poi_type).is_old.delete_all
      Poi.where(poi_type: poi_type).update_all(old: false)
      puts 'Done: Loaded ' + Poi.where(poi_type: poi_type).count.to_s + ' new Stops'
      UserMailer.stops_succeeded_email(Oneclick::Application.config.support_emails.split(',')).deliver!
    end

  end

  desc "Load Landmarks and Stops"
  task :load_new_landmarks_and_stops => :environment do
    Rake::Task['oneclick:load_new_landmarks'].invoke
    Rake::Task['oneclick:load_new_stops'].invoke
  end

end