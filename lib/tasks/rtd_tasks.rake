namespace :oneclick do


  desc "Load new Landmarks"
  task :load_new_landmarks => :environment do

    require 'open-uri'
    include TripsSupport

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
      if p.updated_at < landmarks_file.last_modified
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

          begin
            google_maps_geocode(p, og) unless google_place_geocode(p)
          rescue Exception => e
            puts e
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
        unless Oneclick::Application.config.support_emails.nil?
          UserMailer.landmarks_failed_email(Oneclick::Application.config.support_emails.split(','), error_string, row_string).deliver!
        end
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
      unless Oneclick::Application.config.support_emails.nil?
        UserMailer.landmarks_succeeded_email(Oneclick::Application.config.support_emails.split(','), non_geocoded_pois).deliver!
      end
    end

  end


  def google_place_geocode(poi)
    location_with_address = poi.address1.to_s + ' ' + poi.city.to_s + ', ' + poi.state.to_s + ' ' + poi.zip.to_s
    lat_lon = poi.lat.to_s + ',' + poi.lon.to_s
    
    result = TripsSupport.google_place_search(poi.name.to_s,lat_lon)
    if result.body['status'] != 'ZERO_RESULTS'
      place_id = result.body['predictions'].first['place_id']
      poi.google_place_id = place_id
      poi.save
    else
      result = TripsSupport.google_place_search(location_with_address,lat_lon)
      if result.body['status'] != 'ZERO_RESULTS'
        place_id = result.body['predictions'].first['place_id']
        poi.google_place_id = place_id
        poi.save
      else
        return false
      end
    end
  end

  def google_maps_geocode(poi, og)
    location_with_name = poi.name.to_s + ', ' + poi.city.to_s + ', ' + poi.state.to_s + ' ' + poi.zip.to_s
    location_with_address_and_name = poi.name.to_s + ', ' + poi.address1.to_s + ' ' + poi.city.to_s + ', ' + poi.state.to_s + ' ' + poi.zip.to_s

    geocoded = og.geocode(location_with_name)
    if geocoded[0] and geocoded[2].count > 0 #If there are no errors?
      place_id = geocoded[2].first[:place_id]
      poi.google_place_id = place_id
      poi.save
    else
      #Second try throwing in the address
      geocoded = og.geocode(location_with_address_and_name)
      if geocoded[0] and geocoded[2].count > 0 #If there are no errors?
        place_id = geocoded[2].first[:place_id]
        poi.google_place_id = place_id
        poi.save
      else
       #If the other two attempts fail, just use the Lat,Lng
       reverse_geocoded = og.reverse_geocode(poi.lat, poi.lon)
       if reverse_geocoded[0] and reverse_geocoded[2].count > 0 #No errors?
         place_id = reverse_geocoded[2].first[:place_id]
         poi.google_place_id = place_id
         poi.save
       else
          puts "Unable to find a valid geocode entry for #{poi.name}"
       end
      end
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

    og = OneclickGeocoder.new
    geocoded = 0

    stops = tp.get_stops
    stops.each do |stop|
      #begin
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

        if geocoded < Oneclick::Application.config.geocoding_limit or Oneclick::Application.config.limit_geocoding == false
          #Reverse Geocode the Lat Lng to fill in the City
          reverse_geocoded = og.reverse_geocode(p.lat, p.lon)
          if reverse_geocoded[0] and reverse_geocoded[2].count > 0 #No errors?
            p.city = reverse_geocoded[2].first[:city]
            p.save
          end
          geocoded += 1
          puts "Geocoding " + geocoded.to_s + " of " + stops.count.to_s
        else
          puts 'skipping geocoding'
        end

      #rescue
      #  Poi.where(poi_type: poi_type).is_new.delete_all
      #  Poi.where(poi_type: poi_type).is_old.update_all(old: false)
      #  failed = true
      #  UserMailer.stops_failed_email(Oneclick::Application.config.support_emails.split(',')).deliver!
      #  puts 'Error encountered loading stops from OpenTripPlanner at ' + Oneclick::Application.config.open_trip_planner.to_s
      #  break
      #end
    end

    unless failed
      Poi.where(poi_type: poi_type).is_old.delete_all
      Poi.where(poi_type: poi_type).update_all(old: false)
      puts 'Done: Loaded ' + Poi.where(poi_type: poi_type).count.to_s + ' new Stops'
      UserMailer.stops_succeeded_email(Oneclick::Application.config.support_emails.split(',')).deliver!
    end

  end

  desc "Replace Intersections With Street Address"
  task :replace_intersections => :environment do
    og = OneclickGeocoder.new
    Poi.all.each do |p|

      unless p.address1
        next
      end

      #Intersections from RTD have @ signs in them
      unless ('@').in? p.address1
        next
      end

      street_address = og.get_street_address(og.reverse_geocode(p.lat, p.lon))
      if street_address
        puts 'Replacing ' + p.address1.to_s + ' with ' + street_address.to_s
        p.address1 = street_address
        p.save
      end
    end
  end

  desc "Load Landmarks and Stops"
  task :load_new_landmarks_and_stops => :environment do
    Rake::Task['oneclick:load_new_landmarks'].invoke
    Rake::Task['oneclick:load_new_stops'].invoke
    Rake::Task['oneclick:replace_intersections'].invoke
  end



end