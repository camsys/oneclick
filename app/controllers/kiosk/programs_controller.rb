module Kiosk
  class ProgramsController < ::ProgramsController
    include Behavior

    def back_url
      new_user_characteristic_path_for_ui_mode(@traveler, inline: 1, anchor: 'back')
    end
  end
end
