module Kiosk
  class HomeController < TravelerAwareController
    include Kiosk::Behavior

    def index
      render 'kiosk/shared/home'
    end

  end
end
