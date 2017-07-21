module Export
  class ScheduleSerializer < ExportSerializer
    
    attributes :day, :start_time, :end_time
    
    def day
      object.day_of_week
    end
    
    def start_time
      object.start_seconds
    end
    
    def end_time
      object.end_seconds
    end
    
  end
end
