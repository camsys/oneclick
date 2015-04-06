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
    OneclickConfiguration.create_or_update(:poi_is_loading, true)
    require 'csv'
    require 'open-uri'
    alert_msgs = []
    Rails.logger.info "Loading POI and POI TYPES from file '#{filename}'"
    Rails.logger.info "Starting at: #{Time.now}"

    count_good = 0
    count_bad = 0
    count_failed = 0
    count_poi_type = 0
    count_possible_existing = 0

    open(filename) do |f|
      Poi.delete_all # delete existing ones
      CSV.foreach(f, {:col_sep => ",", :headers => true}) do |row|

        poi_type_name = row[9]
        if poi_type_name.blank?
          poi_type_name = 'Unknown'
        end
        poi_type = PoiType.find_by_name(poi_type_name)
        if poi_type.nil?
          #Rails.logger.info "Adding new poi type #{poi_type_name}"
          poi_type = PoiType.create({:name => poi_type_name, :active => true})
          count_poi_type += 1
        end
        if poi_type
          poi_name = row[2]
          poi_city = row[5]
          #If we have already created this POI, don't create it again.
          if Poi.exists?(name: poi_name, poi_type: poi_type, city: poi_city)
            #Rails.logger.info "Possible duplicate: #{row}"
            count_possible_existing += 1
            next
          end
          
          begin
            if poi_name
              p = Poi.create!({
                poi_type: poi_type,
                lon: row[0],
                lat: row[1],
                name: poi_name,
                address1: row[3],
                address2: row[4],
                city: poi_city,
                state: row[6],
                zip: row[7],
                county: row[8]
              })
              count_good += 1
            else
              count_bad += 1
            end
          rescue Exception => e
            #Rails.logger.info "Failed to save: #{e.message} for #{p.ai}"
            count_failed += 1
          end
        else
          #Rails.logger.info ">>> Can't find POI type '#{poi_type_name}'"
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
    summary_info = I18n.t(:pois_load_summary) % sub_pairs
    OneclickConfiguration.create_or_update(:poi_last_loading_summary, summary_info)
    OneclickConfiguration.create_or_update(:poi_is_loading, false)

    summary_info
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

  def build_place_details_hash
    #Based on Google Place Details

    {
      address_components: [
        {
          long_name: self.address1,
          short_name: self.address1,
          types: ["street_address"]
        },
        {
          long_name: self.city,
          short_name: self.city,
          types: ["locality", "political"]
        },
        {
          long_name: self.state,
          short_name: self.state,
          types: ["administrative_area_level_1","political"]
        },
        {
          long_name: self.zip,
          short_name: self.zip,
          types: ["postal_code"]
        }
      ],

      formatted_address: self.address,
      geometry: {
        location: {
          lat: self.lat,
          lng: self.lon,
        }
      },
      id: self.id,
      name: self.name,
      scope: "Global POI"
    }
  end
  
end
