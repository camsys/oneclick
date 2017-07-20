module Export
  class ServiceSerializer < ExportSerializer

    attributes  :name, 
                :email,
                :url,
                :phone,
                :comments,
                :provider_id,
                :logo,
                :start_or_end_area_recipe,
                :trip_within_area_recipe,
                :published,
                :service_type,
                :fare_structure,
                :fare_details,
                :gtfs_agency_id,
                :accommodations,
                :eligibilities,
                :purposes
                
    has_many :schedules, serializer: Export::ScheduleSerializer
                
    uniquize_attribute :name
    
    FARE_STRUCTURES = { 
      0 => :flat, 
      1 => :mileage, 
      2 => :complex, 
      3 => :zone, 
      4 => :taxi_fare_finder 
    }
    
    SERVICE_TYPES = {
      "paratransit" => :paratransit,
      "volunteer" => :paratransit,
      "nemt" => :paratransit,
      "transit" => :transit,
      "taxi" => :taxi,
      "uber_x" => :uber
    }
    
    def email
      object.email || object.internal_contact_email
    end
    
    def phone
      object.phone || object.internal_contact_phone
    end

    def comments
      object.comments.map {|c| [c.locale, c.comment]}.to_h
    end
    
    def logo
      object.try(:logo_url)
    end
    
    def start_or_end_area_recipe
      object.primary_coverage.try(:recipe)
    end
    
    def trip_within_area_recipe
      object.secondary_coverage.try(:recipe)
    end
    
    def published
      object.active
    end
    
    def service_type
      SERVICE_TYPES[object.service_type.try(:code)]
    end
    
    def fare_structure
      FARE_STRUCTURES[object.fare_structures.first.try(:fare_type)]
    end
    
    def fare_details
      fare_info = object.fare_structures.first
      
      case fare_structure
      when :flat
        return { 
          base_fare: fare_info.base.try(:to_f) 
        }
      when :mileage
        return { 
          base_fare: fare_info.base.try(:to_f),
          mileage_rate: fare_info.rate.try(:to_f),
          trip_type: service_type
        }
      when :complex
        return nil
      when :zone
        return build_fare_zone_details
      when :taxi_fare_finder
        return {
          taxi_fare_finder_city: object.taxi_fare_finder_city
        }
      else
        return nil
      end
      
    end
    
    def gtfs_agency_id
      object.external_id
    end
    
    private
    
    def build_fare_zone_details
      fare_zone_codes = object.fare_zones.pluck(:zone_id).map(&:downcase).sort
      
      fare_zones = fare_zone_codes.map do |z| 
        [z, [{ model: "CustomGeography", attributes: {name: "#{object.name}_zone_#{z}".underscore}}]]
      end.to_h
      
      fare_table = fare_zone_codes.map do |zr|
        [
          zr, 
          fare_zone_codes.map do |zc|
            [zc, find_zone_fare(zr, zc)]
          end.to_h
        ]
      end.to_h
      
      return {
        fare_zones: fare_zones,
        fare_table: fare_table
      }
    end
        
    # Find the appropriate zone far by origin and destination zone code
    def find_zone_fare(origin_zone, destination_zone)
      fare_info = object.fare_structures.first
      
      fare_info.zone_fares.find_by(
        from_zone_id: object.fare_zones.find_by(zone_id: origin_zone.to_s.upcase).id,
        to_zone_id: object.fare_zones.find_by(zone_id: destination_zone.to_s.upcase).id,        
      ).try(:rate)
    end
    
    def accommodations
      object.accommodations.pluck(:code)
    end
    
    def eligibilities
      object.characteristics.pluck(:code)
    end
    
    def purposes
      object.trip_purposes.pluck(:code)
    end
    
  end
end
