module Kiosk
  class AccommodationsController < ::AccommodationsController
    include Behavior

  protected

    def back_url
      get_traveler
      new_kiosk_user_program_path(@traveler, inline: 1)
    end
  end
end
