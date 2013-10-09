#!/usr/bin/env ruby

#
# Loads POIs provided by ARC
#
# POIs are stored in a CSV file
#
require File.dirname(__FILE__) + '/../../config/environment.rb' 
require "rubygems"
require 'csv'

FILENAME = '../../db/arc_poi_data/CommunityFacilities.csv'


puts
puts "Loading POI and POI TYPES from file '#{FILENAME}'"
puts "Starting at: #{Time.now}"

# Delete existing POIs by truncating the tables
%w{poi_types pois}.each do |table_name|
  puts "Truncating table #{table_name}"
  ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{table_name}")
end

# Read the CSV file
csv_file = File.read(FILENAME)
table = CSV.parse(csv_file, :headers => true)
count_good = 0
count_bad = 0
count_poi_type = 0

table.each do |row|  
  #puts row.inspect
  
  poi_type_name = row[17]
  if poi_type_name.blank?
    poi_type_name = 'Unknown'
  end
  poi_type = PoiType.find_by_name(poi_type_name)
  if poi_type.nil?
    puts "Adding new poi type #{poi_type_name}"
    poi_type = PoiType.new({:name => poi_type_name, :active => true})
    poi_type.save!
    count_poi_type += 1
  end
  if poi_type
    p = Poi.new
    p.poi_type = poi_type
    p.lon = row[2]
    p.lat = row[3]
    p.name = row[4]
    p.address1 = row[6]
    p.address2 = row[7]
    p.city = row[8]
    p.state = 'GA'
    p.zip = row[10]
    if p.name && row[2] != "0.0"
      p.save!
      count_good += 1
    else
      count_bad += 1      
    end
  else
    puts ">>> Can't find POI type '#{poi_type_name}'"
  end
end

puts
puts "Loaded #{count_poi_type} POI Types and #{count_good} POIs. #{count_bad} were skipped."


