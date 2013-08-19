class ApplicationController < ActionController::Base
  include CsHelpers
  include LocaleHelpers

  protect_from_forgery
  before_filter :set_locale
  after_filter :clear_location

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, :alert => exception.message
  end

  def current_traveler
    if assisting?
      assisted_user
    else
      current_user
    end
  end

  def clear_location
    session.delete :location
  end

  def start_assisting user
    session[:assisting] = user.id
  end

  def stop_assisting
    session.delete :assisting
  end

end
