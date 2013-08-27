#!/usr/bin/env ruby

#
# Loads a POI file in GPX format into the database. Uses Nokogiri to parse
# the file. A typical record look like
#
# <wpt lat="32.916792500" lon="-85.401615000">
#   <name>Hospital:Batson Memorial Sanitarium</name>
#   <cmt>Hospital:Batson Memorial Sanitarium</cmt>
#   <desc>Hospital:Batson Memorial Sanitarium</desc>
# </wpt>
#

require File.dirname(__FILE__) + '/../../config/environment.rb' 
require "rubygems"

# set this to the state name ypu wish to load
STATE = 'georgia'
DATA_PATH = "../../db/poi_data/"
POI_CLASSES = [
  #'Automotive', 
  #'Eating_Drinking', 
  'Government_and_Public_Services', 
  'Health_care', 
  #'Leisure', 
  #'Lodging', 
  #'Night_life_and_Business',
  #'Sports',
  #'Tourism'
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
  
  pois.each do |poi|
    lat = poi["lat"].to_d
    lon = poi["lon"].to_d
    text = poi.xpath("name").text
    # Split on the separator as the poi names are sub-type:name eg Hospital:Batson Memorial Sanitarium
    elems = text.split(":")
    if elems.count > 1
      poi_type_name = elems[0].strip
      poi_name = elems[1].strip
      
      # See if we can find the poi type
      poi_type = PoiType.find_by_name(poi_type_name)
      if poi_type.nil?
        poi_type = PoiType.new
        poi_type.name = poi_type_name
        poi_type.active = true
        poi_type.save!
      end
      
      # Create the poi
      poi = Poi.new
      poi.name = poi_name
      poi.poi_type = poi_type
      poi.lat = lat
      poi.lon = lon
      poi.save!
    else
      Rails.logger.info("    Skipping " + text)
    end
  end
  
  f.close
    
end

Rails.logger.info "Processing completed"