module Kiosk
  class HomeController < ActionController::Base
    include Kiosk::Behavior
    include CsHelpers

    def index
      @actions = [
        {label: t(:log_in), target: kiosk_user_session_path, icon: ACTION_ICONS[:log_in], not_on_homepage: true},
      ]
      Rails.logger.info "Kiosk::HomeController#index, @actions is #{@actions.ai}"
      render 'kiosk/shared/home'
    end

  end
end
