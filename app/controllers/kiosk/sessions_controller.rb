module Kiosk
  class SessionsController < ::SessionsController
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
      self.resource = warden.authenticate!(auth_options)
      sign_in(resource_name, resource)
      respond_with resource, :location => after_sign_in_path_for(resource)
    end

  end
end
