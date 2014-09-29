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
    require 'csv'
    filename  = Oneclick::Application.config.poi_file
    # FILENAME = File.join(Rails.root, 'db', 'arc_poi_data', 'CommFacil_20131015.txt')

    puts
    puts "Loading POI and POI TYPES from file '#{filename}'"
    puts "Starting at: #{Time.now}"

    # Delete existing POIs by truncating the tables
    #%w{poi_types pois}.each do |table_name|
    #  puts "Truncating table #{table_name}"
    #  ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{table_name}")
    #end

    count_good = 0
    count_bad = 0
    count_failed = 0
    count_poi_type = 0
    count_possible_existing = 0

    File.open(filename) do |f|

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

          #If we have already created this POI, don't create it again.
          if Poi.exists?(name: row[3], poi_type: poi_type, city: row[6])
            puts "Possible duplicate: #{row}"
            count_possible_existing += 1
            # next
          end
          p = Poi.new
          p.poi_type = poi_type
          p.lon = row[1]
          p.lat = row[2]
          p.name = row[3]
          p.address1 = row[4]
          p.address2 = row[5]
          p.city = row[6]
          p.state = row[7]
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
    puts "Loaded #{count_poi_type} POI Types and #{count_good} POIs."
    puts "  #{count_bad} bad were skipped, #{count_failed} failed to save, #{count_possible_existing} possible existing."
    puts "POI Loading Rake Task Finished"
  end
  #THIS IS THE END

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
end
