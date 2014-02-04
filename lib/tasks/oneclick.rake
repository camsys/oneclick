require 'lorem-ipsum'

#encoding: utf-8
namespace :oneclick do
  task :seed_data => :environment do
    throw Exception.new("*** Deprecated, just use db:seed task ***")
  end

  task version: :environment do
    version = `git describe`.chomp
    File.open('config/initializers/version.rb', 'w') do |f|
      f.puts "Oneclick::Application.config.version = '#{version}'"
    end
  end

  task :update_reports => :environment do
    reports = [
      {name: 'Trips Created', description: 'Displays a chart showing the number of trips created each day.', view_name: 'generic_report', class_name: 'TripsCreatedByDayReport', active: 1}, 
      {name: 'Trips Scheduled', description: 'Displays a chart showing the number of trips scheduled for each day.', view_name: 'generic_report', class_name: 'TripsScheduledByDayReport', active: 1}, 
      {name: 'Failed Trips', description: 'Displays a report describing the trips that failed.', view_name: 'trips_report', class_name: 'InvalidTripsReport', active: 1}, 
      {name: 'Rejected Trips', description: 'Displays a report showing trips that were rejected by a user.', view_name: 'trips_report', class_name: 'RejectedTripsReport', active: 1} 
    ]
    
    # Delete existing POIs by truncating the tables
    %w{reports}.each do |table_name|
      puts "Truncating table #{table_name}"
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{table_name}")
    end
    
    # load the reports
    reports.each do |rep|
      r = Report.new(rep)
      puts "Loading report #{r.name}"
      r.save!
    end

  end

  task :update_reports2 => :environment do
    reports = [
      {name: 'Trips Planned', description: 'Trips planned with various breakdowns.',
        view_name: 'breakdown_report', class_name: 'TripsBreakdownReport', active: 1}, 
      ]
      reports.each do |rep|
        r = Report.new(rep)
        puts "Loading report #{r.name}"
        r.save!
      end
    end

    task providers: :environment do
      require File.join(Rails.root, 'db', 'providers')
    end

    task load_pois: :environment do
      require 'csv'

      FILENAME = ENV['FILENAME']
    # FILENAME = File.join(Rails.root, 'db', 'arc_poi_data', 'CommFacil_20131015.txt')

    puts
    puts "Loading POI and POI TYPES from file '#{FILENAME}'"
    puts "Starting at: #{Time.now}"

    # Delete existing POIs by truncating the tables
    %w{poi_types pois}.each do |table_name|
      puts "Truncating table #{table_name}"
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{table_name}")
    end

    count_good = 0
    count_bad = 0
    count_failed = 0
    count_poi_type = 0

    File.open(FILENAME) do |f|

      CSV.foreach(f, {:col_sep => "\t", :headers => true}) do |row|

        poi_type_name = row[13]
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
          p = Poi.new
          p.poi_type = poi_type
          p.lon = row[1]
          p.lat = row[2]
          p.name = row[3]
          p.address1 = row[4]
          p.address2 = row[5]
          p.city = row[6]
          p.state = 'GA'
          p.zip = row[8]
          p.county = row[12]
          begin
            if p.name && row[2] != "0.0"
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
    puts "Loaded #{count_poi_type} POI Types and #{count_good} POIs. #{count_bad} were skipped, #{count_failed} failed to save."
  end 

  # OBJECTID  LONGITUDE LATITUDE  FACNAME ADDRESS_1 ADDRESS_2 CITY  STATE ZIP AREACODE  PHONE FIPS  COUNTY  TYPE  METHOD
  task convert_shp_to_csv: :environment do
    require 'rgeo/shapefile'
    require 'csv'
    geocoder = OneclickGeocoder.new
    poi_types = Set.new
    c = 0
    CSV.open("output.csv", "wb", {col_sep: "\t"}) do |csv|
      csv << %w{OBJECTID  LONGITUDE LATITUDE  FACNAME ADDRESS_1 ADDRESS_2 CITY  STATE ZIP AREACODE  PHONE FIPS  COUNTY  TYPE  METHOD}
      RGeo::Shapefile::Reader.open(ENV['SHAPEFILE']) do |shapefile|
        input_rows = shapefile.size
        shapefile.each do |shape|
          # puts shape.inspect
          begin
            success, errors, results = geocoder.reverse_geocode(shape.geometry.y, shape.geometry.x)
            unless success
              puts "Geocode failed:"
              puts errors.inspect
              puts shape.inspect
              sleep(10)
              next
            end
            result = results[0]
            csv << [shape['ObjectID'], shape.geometry.x, shape.geometry.y, shape['NAME'], result[:street_address],
            nil,
            result[:city], result[:state], result[:zip], nil, nil, shape['STCTYFIPS'], result[:county],
            shape['FEATTYPE'], 'ArcGIS']
            poi_types << shape['FEATTYPE']
            # break if c >= 2
          rescue Exception => e
            puts "Exception: #{e}"
            puts "Shape: #{shape.inspect}"
          end
          c += 1
          puts "#{c} / #{input_rows}"
          # sleep(rand(5))
        end
      end
    end

    puts poi_types.to_a.join("\n")

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

  task generate_trips: :environment do
    users = (1..100).each.collect do |i|
      random_string = ((0...16).map { (65 + rand(26)).chr }.join)
      u = User.new
      u.first_name = "Visitor"
      u.last_name = "Guest"
      u.password = random_string
      u.email = "guest_#{random_string}@example.com" 
      u.save!(:validate => false)      
      Rails.logger.info "Generated user"
      u
    end
    users.each do |u|
      u.user_profile.user_traveler_characteristics_maps.create! traveler_characteristic: TravelerCharacteristic.where(datatype: 'bool').sample,
      value: [true, false].sample
      u.user_profile.user_traveler_characteristics_maps.create! traveler_characteristic: TravelerCharacteristic.where(datatype: 'bool').sample,
      value: [true, false].sample
      u.user_profile.user_traveler_characteristics_maps.create! traveler_characteristic: TravelerCharacteristic.where(datatype: 'bool').sample,
      value: [true, false].sample
      Rails.logger.info "Added characterstics to user"
    end
    users.each_with_index do |u, ui|
      (1..100).each do |i|
        text_size = rand(200)
        t = u.trips.create! trip_purpose: TripPurpose.all.sample,
          user_comments: LoremIpsum.generate.truncate(text_size, omission: '').split.sample(text_size).join(' '),
          taken: [true, false].sample,
          rating: [nil, [*0..5]].flatten.sample
        t.trip_parts.create! from_trip_place: TripPlace.all.sample, to_trip_place: TripPlace.all.sample, sequence: 0,
          scheduled_date: (Date.today + rand(-30..30).days), scheduled_time: Time.now
        Rails.logger.info "Added trip #{i} to user #{ui}"
      end
    end
  end

end
