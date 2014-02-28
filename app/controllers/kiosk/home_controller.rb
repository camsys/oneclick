module Kiosk
  class HomeController < ApplicationController
    include Kiosk::Behavior
    include CsHelpers

    def index
      @actions = [
        {label: t(:plan_a_trip), target: kiosk_user_new_trip_start_path(user_id: get_traveler.id), icon: ACTION_ICONS[:plan_a_trip]}
      ]

      Rails.logger.info "Kiosk::HomeController#index, @actions is #{@actions.ai}"
      render 'kiosk/shared/home'
    end

    def reset
      reset_session
      render layout: false
    end

  protected

    def back_url
      '/'
    end

  end
end
