class Poi < GeocodedAddress
  
  # Associations
  belongs_to :poi_type

  #after_validation :reverse_geocode
  
  # Updatable attributes
  # attr_accessible :name

  # set the default scope
  default_scope {order('pois.name')}

  def self.get_by_query_str(query_str, limit)
    rel = Poi.arel_table[:name].matches(query_str)
    pois = Poi.where(rel).limit(limit)
    pois
  end

  def self.load_pois(filename)
    require 'csv'
    alert_msgs = []
    Rails.logger.info "Loading POI and POI TYPES from file '#{filename}'"
    Rails.logger.info "Starting at: #{Time.now}"

    count_good = 0
    count_bad = 0
    count_failed = 0
    count_poi_type = 0
    count_possible_existing = 0

    File.open(filename) do |f|

      CSV.foreach(f, {:col_sep => ",", :headers => true}) do |row|

        poi_type_name = row[9]
        if poi_type_name.blank?
          poi_type_name = 'Unknown'
        end
        poi_type = PoiType.find_by_name(poi_type_name)
        if poi_type.nil?
          Rails.logger.info "Adding new poi type #{poi_type_name}"
          poi_type = PoiType.create!({:name => poi_type_name, :active => true})
          count_poi_type += 1
        end
        if poi_type

          #If we have already created this POI, don't create it again.
          if Poi.exists?(name: row[2], poi_type: poi_type, city: row[5])
            Rails.logger.info "Possible duplicate: #{row}"
            count_possible_existing += 1
            next
          end
          p = Poi.new
          p.poi_type = poi_type
          p.lon = row[1]
          p.lat = row[0]
          p.name = row[2]
          p.address1 = row[3]
          p.address2 = row[4]
          p.city = row[5]
          p.state = row[6]
          p.zip = row[7]
          p.county = row[8]
          begin
            if p.name && p.lat != "0.0"
              p.save!
              count_good += 1
            else
              count_bad += 1
            end
          rescue Exception => e
            Rails.logger.info "Failed to save: #{e.message} for #{p.ai}"
            count_failed += 1
          end
        else
          Rails.logger.info ">>> Can't find POI type '#{poi_type_name}'"
        end
      end
    end

    Rails.logger.info "POI Loading Finished"

    sub_pairs = {
      count_poi_type: count_poi_type,
      count_good: count_good,
      count_failed: count_failed,
      count_bad: count_bad,
      count_possible_existing: count_possible_existing
    }

    I18n.t(:pois_load_summary) % sub_pairs
  end

  def to_s
    name
  end
  
  def county_name
    return get_county_name
  end
  
  def location
    return get_location
  end
  
  def zipcode
    return get_zipcode
  end
  
  def geocode
    reverse_geocode
    self.save
  end
  
  def address
    get_address
  end
  
  reverse_geocoded_by :lat, :lon do |obj, results|
    if results.first
      geo = results.first
      obj.address1  = geo.street_address
      obj.city      = geo.city
      obj.zip       = geo.postal_code
      obj.state     = geo.state_code
      obj.county    = geo.county
    end
  end

  def type_name
    'POI_TYPE'
  end
  
end
