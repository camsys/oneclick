require 'lorem-ipsum'

class Hash
  def each_with_parents(parents=[], &blk)
    each do |k, v|
      Hash === v ? v.each_with_parents(parents + [k], &blk) : blk.call([parents + [k], v])
    end
  end
end

def traverse(obj, parents=[], &blk)
  case obj
  when Hash
    obj.each do |k, v|
      blk.call(v, parents + [k]) if v.is_a? Hash
      traverse(v, parents + [k], &blk)
    end
    # when Array
    #   obj.each do |v|
    #     traverse(v, parents, &blk)
    #   end
  else
    blk.call(obj, parents)
  end
end

#encoding: utf-8
namespace :oneclick do

  desc "Sets mode icons to point to S3"
  task :set_mode_icons => :environment do
    bucket = ENV['AWS_BUCKET'].nil? ? "oneclick-#{Oneclick::Application.config.brand}" : ENV['AWS_BUCKET']
    full_url = "https://s3.amazonaws.com/#{bucket}/modes/"
    puts "----------------------------"
    puts full_url
    puts "----------------------------"

    Mode.unscoped.each do |mode|
      old_logo = mode.logo_url.match('\w*(.png)')[0]
      mode.logo_url = full_url + old_logo
      if mode.save
        puts "Mode: #{mode} | Logo: #{mode.logo_url}"
      end
    end
  end

  desc "Sets default logo"
  task :set_default_logo=> :environment do
    bucket = ENV['AWS_BUCKET'].nil? ? "oneclick-#{Oneclick::Application.config.brand}" : ENV['AWS_BUCKET']
    full_url = "https://s3.amazonaws.com/#{bucket}/images/logo.png"
    puts "----------------------------"
    puts full_url
    puts "----------------------------"

    oc = OneclickConfiguration.where(code: "ui_logo").first_or_create
    oc.value = full_url
    oc.save
  end

  task :seed_data => :environment do
    throw Exception.new("*** Deprecated, just use db:seed task ***")
  end

  task version: :environment do
    version = `git describe`.chomp
    File.open('config/initializers/version.rb', 'w') do |f|
      f.puts "Oneclick::Application.config.version = '#{version}'"
    end
  end

  task extract_shp: :environment do
    require 'rgeo/shapefile'
    # require 'csv'
    # geocoder = OneclickGeocoder.new
    poi_types = Set.new
    c = 0
    type_count = Hash.new(0)
    CSV.open("output.csv", "wb", {col_sep: "\t"}) do |csv|
      csv << %w{OBJECTID  LONGITUDE LATITUDE  FACNAME ADDRESS_1 ADDRESS_2 CITY  STATE ZIP AREACODE  PHONE FIPS  COUNTY  TYPE  METHOD}
      Dir.glob('/Users/dedwards/Downloads/ParatransitBuffer_100812/*.shp').each do |shp|
        puts shp
        RGeo::Shapefile::Reader.open(shp) do |shapefile|
          # input_rows = shapefile.size
          shapefile.each do |shape|
            next if shape['NAME'].blank?
            # puts shape.attributes.select{|k, v| !v.blank?}
            shape.attributes.select{|k, v| !v.blank? and !['OSM_ID', 'NAME'].include?(k)}.each do |k, v|
              type_count[[k, v].join('|')] += 1
            end

            # AMENITY, LANDUSE, LEISURE, PLACE, SHOP, TOURISM
            # puts shape.geometry.x/(10**5)
            # puts shape.geometry.y/(10**5)
            # puts
            row = [shape['OSM_ID']]
            row << shape.geometry.x/(10**5)
            row << shape.geometry.y/(10**5)
            row << shape['NAME']
            row << nil # street address
            row << nil
            row << nil # city
            row << nil # state
            row << nil # zip
            row << nil
            row << nil
            row << nil # county FIPS
            row << nil # county
            row << (%w{AMENITY LANDUSE LEISURE PLACE SHOP TOURISM} & shape.attributes.keys).first
            row << 'OSM'
            csv << row
            c += 1
          end
        end
      end
    end

    # puts c
    # type_count.each do |k, v|
    #   puts [k, v].join("\t")
    # end
  end

  task fix_roles: :environment do
    Role.destroy_all
    ROLES.each do |r|
      Role.create! name: r
    end
    # For old times's sake
    Role.create! name: :admin
    u = User.find_by_email('email@camsys.com')
    u.add_role 'System Administrator'
    u.add_role :admin
  end

  task build_polygons: :environment do
    Service.all.each do |service|
      puts 'Buliding shape for ' + service.name.to_s
      service.build_polygons
    end
  end

  task load_pois: :environment do
    require 'open-uri'
    require 'csv'
    filename  = Oneclick::Application.config.poi_file

    puts
    puts "Loading POI and POI TYPES from file '#{filename}'"
    puts "Starting at: #{Time.now}"

    count_good = 0
    count_bad = 0
    count_failed = 0
    count_poi_type = 0
    count_possible_existing = 0

    open(filename) do |f|

      CSV.foreach(f, {:col_sep => ",", :headers => true}) do |row|

        poi_type_name = row[9]
        if poi_type_name.blank?
          poi_type_name = 'Unknown'
        end
        poi_type = PoiType.find_by_name(poi_type_name)
        if poi_type.nil?
          puts "Adding new poi type #{poi_type_name}"
          poi_type = PoiType.create!({:name => poi_type_name, :active => true})
          count_poi_type += 1
        end
        if poi_type

          #If we have already created this POI, don't create it again.
          if Poi.exists?(name: row[2], poi_type: poi_type, city: row[6])
            puts "Possible duplicate: #{row}"
            count_possible_existing += 1
            next
          end
          p = Poi.new
          p.poi_type = poi_type
          p.lon = row[0]
          p.lat = row[1]
          p.name = row[2]
          p.address1 = row[3]
          p.address2 = row[4]
          p.city = row[5]
          p.state = row[6]
          p.zip = row[7]
          p.county = row[8]
          begin
            if p.name && row[0] != "0.0"
              p.save!
              count_good += 1
            else
              count_bad += 1
            end
          rescue Exception => e
            puts "Failed to save: #{e.message} for #{p.ai}"
            count_failed += 1
          end
        else
          puts ">>> Can't find POI type '#{poi_type_name}'"
        end
      end
    end
    puts
    puts "Loaded #{count_poi_type} POI Types and #{count_good} POIs."
    puts "  #{count_bad} bad were skipped, #{count_failed} failed to save, #{count_possible_existing} possible existing."
    puts "POI Loading Rake Task Finished"
  end
  #THIS IS THE END

  def wrap s, p, c
    "[#{p}#{c}]#{s}[#{p}]"
  end

  def quote s
    q = (s =~ /\"/ ? '\'' : '"')
    "#{q}#{s}#{q}"
  end

  task print_booking_report: :environment do
    #Get all new trips from today:
    puts Time.zone.now
    puts '=========================================='
    puts 'Trips Created in last 24 hours.'
    puts '=========================================='
    trips = Trip.where("created_at >= ?", Time.zone.now - (3600*25))
    trips.each do |trip|
      if trip.is_booked?
        puts trip.user.name
        puts 'Trip Id ' + trip.id.to_s
        puts 'From: ' + trip.origin.raw_address
        puts 'To: ' + trip.destination.raw_address
        trip.trip_parts.each do |tp|
          if tp.is_booked?
            if tp.is_return_trip
              puts 'Return Trip:'
            else
              puts 'Outbound Trip:'
            end
            puts tp.scheduled_time
            puts tp.selected_itinerary.booking_confirmation
          end
        end
        puts '-------------------------'
      end
    end

    puts '=========================================='
    puts 'Trips scheduled for the next two weeks'
    puts '=========================================='
    trip_parts = TripPart.where("scheduled_time >= ? AND scheduled_time <= ?", Time.zone.now.beginning_of_day, Time.zone.now.beginning_of_day + (3600*14*24)).sort_by{|x| x.scheduled_time}
    trip_parts.each do |tp|
      if tp.is_booked?
        puts 'Trip_part id: '  + tp.id.to_s
        puts tp.trip.user.name
        puts tp.scheduled_time
        if tp.is_return_trip
          puts 'Return Trip'
          puts tp.trip.destination.raw_address
          puts tp.trip.origin.raw_address
        else
          puts 'Outbound Trip'
          puts tp.trip.origin.raw_address
          puts tp.trip.destination.raw_address
        end
        puts tp.selected_itinerary.booking_confirmation
        puts '-----------------------'
      end
    end

  end

  desc "Create Mode Table entries for Ferry, Cable Car, Gondola, and Funicular"
  task add_otp_modes: :environment do

    bucket = ENV['AWS_BUCKET'].nil? ? "oneclick-#{Oneclick::Application.config.brand}" : ENV['AWS_BUCKET']
    full_url = "https://s3.amazonaws.com/#{bucket}/modes/"

    ['FERRY', 'CABLE_CAR', 'GONDOLA', 'FUNICULAR', 'SUBWAY', 'TRAM'].each do |m|

      mode = Mode.unscoped.where(code: 'mode_' + m.downcase).first_or_initialize
      unless mode.persisted?
        puts 'Creating ' + m
        mode.name = "mode_" + m.downcase + "_name"
        mode.logo_url = full_url + m.downcase + '.png'
        mode.active = true
        mode.visible = false
        mode.otp_mode = m
        mode.save
      else
        puts 'Skipping ' + m
      end
    end
  end

  desc "Query planned trips and update is_planned column"
  task scan_trips_is_planned: :environment do

    puts 'find out trip_parts grouped by trip_id'
    trip_part_by_trip_count = TripPart.includes(:trip).references(:trip).group("trips.id").count

    puts 'find out selected itineraries grouped by trip_id'
    selected_itins_by_trip_count = Itinerary.includes(trip_part: :trip).references(trip_part: :trip)
      .where(selected: true)
      .group("trips.id").count
    
    puts 'find trip ids with trip_part_count == selected_itins_count'
    planned_trip_ids = []
    trip_part_by_trip_count.merge(selected_itins_by_trip_count) {|k, n, o| planned_trip_ids << k if n == o}

    Trip.where(id: planned_trip_ids).update_all(is_planned: true)
    Trip.where.not(id: planned_trip_ids).update_all(is_planned: false)

    puts 'finished scanning planned trips'
  end

  desc "Create sql view for trips page"
  task create_trips_sql_view: :environment do

    ActiveRecord::Base.connection.execute File.read(Rails.root.join('lib/tasks/sql/trips_view.sql'))

    puts 'trips_view is created'
  end

  desc "Create Funding Source Objects for Ecolane/Rabbit"
  task create_funding_sources: :environment do
    funding_sources = Oneclick::Application.config.funding_source_order
    services = Service.where(booking_service_code: "ecolane")
    services.each do |s|
      funding_sources.each_with_index do |fs,i|
        FundingSource.where(code: fs, service: s).first_or_create do |new_fs|
          new_fs.index = i
          new_fs.save
        end
      end
    end
  end

  desc 'add returned_mode_code'
  task add_returned_mode_codes: :environment do
    itins = Itinerary.where(returned_mode_code: nil)
    itins.each do |itin|
      if itin.mode
        itin.returned_mode_code = itin.mode.code
        itin.save

      end
    end
  end

  desc "Setup Ecolane Services"
  task setup_ecolane_services: :environment do

    #Before running this task:  For each service with ecolane booking, set the Service Id to the lowercase county name
    #and set the Booking Service Code to 'ecolane' These fields are found on the service profile page

    #Define which funding_sources are ADA, used for determining the questions
    oc = OneclickConfiguration.where(code: "ada_funding_sources").first_or_create
    oc.value = ["ADAYORK1", "ADAYORK2", "ADA"]
    puts 'The following funding sources are considered to be ADA'
    puts oc.value
    oc.save

    services = Service.where(booking_service_code: "ecolane")

    services.each do |service|


      #Funding source array cheat sheet
      # 0: code
      # 1: index (lower gives higher priority when trying to match funding sources to trip purposes)
      # 2: general_public (is the the general public funding source?)
      # 3: comment

      if service
        county = service.external_id
        puts 'Setting up ' + service.name || service.id.to_s

        case county
        when 'york'


          #Funding Sources
          funding_source_array = [['Lottery', 0, false, 'Riders 65 or older'], ['PWD', 1, false, "Riders with disabilities"], ['MATP', 2, false, "Medical Transportation"], ["ADAYORK1", 3, false, "Eligible for ADA"], ["ADAYORK2", 4, false, "Eligible for ADA"], ["Gen Pub", 5, true, "Full Fare"]]
          service.funding_sources.destroy_all
          funding_source_array.each do |fs|
            new_funding_source = FundingSource.where(service: service, code: fs[0]).first_or_create
            new_funding_source.index = fs[1]
            new_funding_source.general_public = fs[2]
            new_funding_source.comment = fs[3]
            new_funding_source.save
          end

          #Dummy User
          service.fare_user = "79109"

          #Booking System Id
          service.booking_system_id = 'rabbit'

          #Confirm API Token is set
          if service.booking_token.nil?
            puts 'Be sure to setup a booking token for ' + service.name
          end

          service.save

        when 'lebanon'


          #Funding Sources
          funding_source_array = [['Lottery', 0, false, 'Riders 65 or older'], ['PwD', 1, false, "Riders with disabilities"], ['MATP', 2, false, "Medical Transportation"], ["ADA", 4, false, "Eligible for ADA"], ["Gen Pub", 5, true, "Full Fare"]]
          service.funding_sources.destroy_all
          funding_source_array.each do |fs|
            new_funding_source = FundingSource.where(service: service, code: fs[0]).first_or_create
            new_funding_source.index = fs[1]
            new_funding_source.general_public = fs[2]
            new_funding_source.comment = fs[3]
            new_funding_source.save
          end

          #Dummy User
          service.fare_user = "79110"

          #Booking System Id
          service.booking_system_id = 'lebanon'

          #Confirm API Token is set
          if service.booking_token.nil?
            puts 'Be sure to setup a booking token for ' + service.name
          end

          service.save

        when 'cambria'

          #Funding Sources
          funding_source_array = [['Lottery', 0, false, 'Riders 65 or older'], ['PwD', 1, false, "Riders with disabilities"], ["ADA", 3, false, "Eligible for ADA"], ["Gen Pub", 5, true, "Full Fare"]]
          service.funding_sources.destroy_all
          funding_source_array.each do |fs|
            new_funding_source = FundingSource.where(service: service, code: fs[0]).first_or_create
            new_funding_source.index = fs[1]
            new_funding_source.general_public = fs[2]
            new_funding_source.comment = fs[3]
            new_funding_source.save
          end

          #Dummy User
          service.fare_user = "7832"

          #Booking System Id
          service.booking_system_id = 'cambria'

          #Confirm API Token is set
          if service.booking_token.nil?
            puts 'Be sure to setup a booking token for ' + service.name
          end

          service.save

        when 'franklin'

          #Funding Sources
          funding_source_array = [['Lottery', 0, false, 'Riders 65 or older'], ['PwD', 1, false, "Riders with disabilities"],['MATP', 2, false, "Medical Transportation"], ["Gen Pub", 5, true, "Full Fare"]]
          service.funding_sources.destroy_all
          funding_source_array.each do |fs|
            new_funding_source = FundingSource.where(service: service, code: fs[0]).first_or_create
            new_funding_source.index = fs[1]
            new_funding_source.general_public = fs[2]
            new_funding_source.comment = fs[3]
            new_funding_source.save
          end

          #Dummy User
          service.fare_user = "2581"

          #Booking System Id
          service.booking_system_id = 'franklin'

          #Confirm API Token is set
          if service.booking_token.nil?
            puts 'Be sure to setup a booking token for ' + service.name
          end

          service.save

        when 'dauphin'

          #Funding Sources
          funding_source_array = [['Lottery', 0, false, 'Riders 65 or older'], ['PwD', 1, false, "Riders with disabilities"],['MATP', 2, false, "Medical Transportation"], ["ADA", 3, false, "Eligible for ADA"], ["Gen Pub", 5, true, "Full Fare"]]
          service.funding_sources.destroy_all
          funding_source_array.each do |fs|
            new_funding_source = FundingSource.where(service: service, code: fs[0]).first_or_create
            new_funding_source.index = fs[1]
            new_funding_source.general_public = fs[2]
            new_funding_source.comment = fs[3]
            new_funding_source.save
          end

          #Dummy User
          service.fare_user = "79109"

          #Booking System Id
          service.booking_system_id = 'dauphin'

          #Confirm API Token is set
          if service.booking_token.nil?
            puts 'Be sure to setup a booking token for ' + service.name
          end

          service.save

        else
          puts 'Cannot find service with external_id: ' + county
        end
      else

      end
    end

end

  desc "Move FareStructure#desc to Comment table"
  task transfer_fare_comments_to_comments_table: :environment do
    FareStructure.where.not(desc: nil).each do |fare_structure|
      comment_en = fare_structure.public_comments.first_or_create(locale: 'en')
      comment_en.update_attributes(comment: fare_structure.desc, visibility: 'public')
    end
  end

end
