module Kiosk
  class HomeController < ActionController::Base
    include Kiosk::Behavior
    include CsHelpers

    def index
      @actions = if user_signed_in?
        [
          {label: t(:plan_a_trip), target: new_kiosk_user_trip_path(user_id: get_traveler.id), icon: ACTION_ICONS[:plan_a_trip]}
        ]
      else
        [
          {label: t(:log_in), target: new_kiosk_user_session_path, icon: ACTION_ICONS[:log_in], not_on_homepage: true}
        ]
      end

      Rails.logger.info "Kiosk::HomeController#index, @actions is #{@actions.ai}"
      render 'kiosk/shared/home'
    end

  end
end
