#!/usr/bin/env ruby

#
# Loads a POI file in GPX format into the database. Uses Nokogiri to parse
# the file
#
require File.dirname(__FILE__) + '/../../config/environment.rb' 
require "rubygems"

# set this to the state name ypu wish to load
STATE = 'georgia'
DATA_PATH = "../../db/poi_data/"
POI_CLASSES = [
  'Automotive', 
  'Eating_Drinking', 
  'Government_and_Public_Services', 
  'Health_care', 
  'Leisure', 
  'Lodging', 
  'Night_life_and_Business',
  'Sports',
  'Tourism'
  ]
  
folder_path = DATA_PATH + STATE

Rails.logger.info "Loading POIs for #{STATE} from #{folder_path}"

POI_CLASSES.each do |poi_class|
  file_name = folder_path + "/" + STATE + "_" + poi_class + ".gpx"
  Rails.logger.info "Loading POIs for #{poi_class} from #{file_name}"

  f = File.open(file_name)
  doc = Nokogiri::XML(f)
  
  root = doc.root
  doc.remove_namespaces!
  Rails.logger.info("  Version " + root["version"] + " Creator " + root["creator"])
  pois = root.xpath("wpt")  
  Rails.logger.info("  Found " + pois.count.to_s + " records.")
  
  f.close
    
end

Rails.logger.info "Processing completed"