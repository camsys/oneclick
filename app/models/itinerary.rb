class Itinerary < ActiveRecord::Base

  attr_accessible :duration, :cost, :end_time, :legs, :message, :mode, :start_time, :status, :transfers, :transit_time,
    :wait_time, :walk_distance, :walk_time, :icon_dictionary, :hidden, :count
  belongs_to :trip

  def self.get_mode_icon(mode)
    @icon_dictionary = {'WALK' => 'travelcon-walk', 'TRAM' => 'travelcon-subway', 'SUBWAY' => 'travelcon-subway', 'RAIL' => 'travelcon-train', 'BUS' => 'travelcon-bus', 'FERRY' => 'travelcon-boat'}
    @icon_dictionary.default = 'travelcon-bus'
    @icon_dictionary[mode]
  end

  def self.failed_trip_ids
    select('DISTINCT trip_id').where('status <> 200').order('trip_id')
  end
  
  def unhide
    self.hidden = false
    self.save()
  end

  def hide
    self.hidden = true
    self.save()
  end

end
