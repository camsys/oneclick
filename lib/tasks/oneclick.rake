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

  task arc_poi: :environment do
    require 'csv'

    FILENAME = File.join(Rails.root, 'db', 'arc_poi_data', 'CommFacil_20131015.txt')

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

end

