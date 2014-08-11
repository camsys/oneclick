class TravelerAwareController < ApplicationController
  before_action do |controller|
    if params[:user_id]
      get_traveler
      if params[:user_id] != @traveler.id.to_s && ENV['UI_MODE'] != 'kiosk'
        raise CanCan::AccessDenied.new
      end
    end
  end
end
