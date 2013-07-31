class Itinerary < ActiveRecord::Base

  attr_accessible :duration, :cost, :end_time, :legs, :message, :mode, :start_time, :status, :transfers, :transit_time, :wait_time, :walk_distance, :walk_time, :icon_dictionary
  belongs_to :trip


  def self.get_mode_icon(mode)
    @icon_dictionary = {'WALK' => 'travelcon-walk', 'TRAM' => 'travelcon-subway', 'SUBWAY' => 'travelcon-subway', 'RAIL' => 'travelcon-train', 'BUS' => 'travelcon-bus', 'FERRY' => 'travelcon-boat'}
    @icon_dictionary.default = 'travelcon-bus'
    @icon_dictionary[mode]
  end

  def duration_to_words(time_in_seconds)
    if !time_in_seconds
      return 'n/a'
    end
    time_in_seconds = time_in_seconds.to_i
    hours = time_in_seconds/3600
    minutes = (time_in_seconds - (hours * 3600))/60

    time_string = ''
    if hours > 0
      time_string << I18n.translate(:hour, count: hours)  + ' '
    end

    if minutes > 0 || hours > 0
      time_string << I18n.translate(:minute, count: minutes)
    end

    if time_in_seconds < 60
      time_string = I18n.translate(:less_than_one_minute)
    end

    time_string

  end

end
