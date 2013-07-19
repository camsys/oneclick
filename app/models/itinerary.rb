class Itinerary < ActiveRecord::Base
  include ActionView::Helpers::TextHelper

  attr_accessible :duration, :cost, :end_time, :legs, :message, :start_time, :status, :transfers, :transit_time, :wait_time, :walk_distance, :walk_time, :icon_dictionary
  belongs_to :trip


  def get_mode_icon(mode)
    @icon_dictionary = {'WALK' => 'travelcon-walk', 'TRAM' => 'travelcon-subway', 'SUBWAY' => 'travelcon-subway', 'RAIL' => 'travelcon-train', 'BUS' => 'travelcon-bus', 'FERRY' => 'travelcon-boat'}
    @icon_dictionary.default = 'travelcon-bus'
    @icon_dictionary[mode]
  end

  def duration_to_words
    if !self.duration
      return 'n/a'
    end
    hours = self.duration/3600
    minutes = (self.duration%3600)/60

    time_string = ''
    if hours > 0
      time_string << pluralize(hours, 'hour')  + ' '

    end
    if minutes > 0 || hours > 0
      time_string << pluralize(minutes, 'minute')
    end
    if self.duration < 60
      time_string = "less than 1 minute"
    end

    time_string

  end

end
