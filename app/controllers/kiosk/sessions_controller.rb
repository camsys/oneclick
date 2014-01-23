module Kiosk
  class SessionsController < Devise::SessionsController
    include Kiosk::Behavior

    def after_sign_up_path_for resource
      Rails.logger.info "Kiosk::SessionsController#after_sign_up_path_for"
      new_kiosk_user_trip_path resource
    end

    def after_sign_in_path_for resource
      Rails.logger.info "Kiosk::SessionsController#after_sign_in_path_for"
      new_kiosk_user_trip_path resource
    end

    def new
      super
    end
    
    def create
      super
    end
    
  end
end
