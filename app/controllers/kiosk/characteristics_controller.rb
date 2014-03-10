module Kiosk
  class CharacteristicsController < ::CharacteristicsController
    include Behavior

    def back_url
      kiosk_user_new_trip_overview_path
    end
  end
end
