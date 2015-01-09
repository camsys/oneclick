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

  desc "Load database translations from config/locales/moved-to-db/*.yml files (idempotent)"
  task load_locales: :environment do
    Dir.glob('config/locales/moved-to-db/*').each do |file|
      puts "Loading locale file #{file}"
      I18n::Utility.load_locale file
    end
  end

  def wrap s, p, c
    "[#{p}#{c}]#{s}[#{p}]"
  end

  def quote s
    q = (s =~ /\"/ ? '\'' : '"')
    "#{q}#{s}#{q}"
  end

  task rewrite_locale: :environment do
    raise "INFILE= must be defined" unless ENV['INFILE']
    y = YAML.load_file(ENV['INFILE'])
    p = ENV['PREFIX']
    raise "PREFIX= must be defined" unless p
    c = 0
    traverse( y ) do |v, parents|
      indent = ' ' * (parents.size-1) * 2
      case v
      when Hash
        if parents.size==1
          puts "#{indent}#{p}:"
        else
          puts "#{indent}#{parents.last}:"
        end
      when Array
        puts "#{indent}#{parents.last}:"
        v.each do |l|
          puts "#{indent}- #{quote(wrap(l, p, c))}"
        end
      when String
        q = (v =~ /\"/ ? '\'' : '"')
        puts "#{indent}#{parents.last}: #{quote(wrap(v, p, c))}"
      else
        raise "Don't know how to handle #{v.inspect}"
      end
      c += 1
    end

    # y.each_with_parents do |parents, v|
    #   locale = parents.shift
    #   if v.is_a? Array
    #     puts "ARRAY"
    #     puts
    #     Translation.create(key: parents.join('.'), locale: locale, value: v.join(','), is_list: true).id.nil? ? failed += 1 : success += 1
    #   else
    #     Translation.create(key: parents.join('.'), locale: locale, value: v).id.nil? ? failed += 1 : success += 1
    #   end
    # end
    # puts "Read #{success+failed} keys, #{success} successful, #{failed} failed, #{skipped} skipped"
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

end
