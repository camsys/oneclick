class TravelerAwareController < ApplicationController
  before_action :confirm_traveler, :except => [:new]
  before_action :confirm_traveler_new, :only => [:new]

  private
    def confirm_traveler
      if params[:user_id]
        get_traveler
        if params[:user_id] != @traveler.id.to_s && ENV['UI_MODE'] != 'kiosk'
          raise CanCan::AccessDenied.new
        end
      end
    end

    #If you are trying to create a new trip and you aren't the correct user, go to the landing page instead
    def confirm_traveler_new
      if params[:user_id]
        get_traveler
        if params[:user_id] != @traveler.id.to_s && ENV['UI_MODE'] != 'kiosk'
          redirect_to root_url
        end
      end
    end
  end
