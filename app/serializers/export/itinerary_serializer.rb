module Export
  class ItinerarySerializer < ExportSerializer

    attributes  :created_at,
                :updated_at,
                :start_time,
                :end_time,
                :legs,
                :walk_time,
                :transit_time,
                :cost,
                :service_id,
                :mode,
                :walk_distance,
                :wait_time,
                :selected
                
    def mode
      object.mode.try(:code)
    end
    
    def legs
      (YAML.load(object.legs.to_s) || nil).as_json
    end
    
  end
end
