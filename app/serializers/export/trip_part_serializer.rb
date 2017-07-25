module Export
  class TripPartSerializer < ExportSerializer

    attributes  :arrive_by, 
                :trip_time, 
                :origin_attributes, 
                :destination_attributes,
                :created_at,
                :user_id
                
    has_many :itineraries, serializer: Export::ItinerarySerializer
    
    def arrive_by
      !object.is_depart
    end
    
    def trip_time
      object.scheduled_time
    end
    
    def origin_attributes
      TripPlaceSerializer.new(object.try(:from_trip_place)).serializable_hash || {}
    end
    
    def destination_attributes
      TripPlaceSerializer.new(object.try(:to_trip_place)).serializable_hash || {}
    end
    
    def user_id
      object.trip.try(:user_id)
    end

  end
end
