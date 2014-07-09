class TravelerAwareController < ApplicationController

  before_action do |controller|
    if params[:user_id]
      unless params[:user_id] == @traveler.id.to_s
        raise CanCan::AccessDenied.new
      end
    end
  end

end
