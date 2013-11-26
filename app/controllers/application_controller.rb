class ApplicationController < ActionController::Base
  include CsHelpers
  include LocaleHelpers

  # include the helper method in any controller which needs to know about guest users
  helper_method :current_or_guest_user
  
  protect_from_forgery
  before_filter :set_locale
  before_filter :get_traveler
  before_filter :setup_actions
  after_filter :clear_location

  # Session key for storing the traveler id
  TRAVELER_USER_SESSION_KEY = 'traveler'

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

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def default_url_options(options={})
    { :locale => ((I18n.locale == I18n.default_locale) ? nil : I18n.locale) }
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

  def set_no_cache
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end

  ######################################################################
  #
  # Manage guest users
  #
  ######################################################################
  
  # if user is logged in, return current_user, else return guest_user
  def current_or_guest_user
    if current_user
      if session[:guest_user_id]
        logging_in
        #guest_user.destroy
        session[:guest_user_id] = nil
      end
      current_user
    else
      guest_user
    end
  end
  
  # find guest_user object associated with the current session,
  # creating one as needed
  def guest_user
    # Cache the value the first time it's gotten.
    @cached_guest_user ||= User.find(session[:guest_user_id] ||= create_guest_user.id)

    rescue ActiveRecord::RecordNotFound # if session[:guest_user_id] invalid
     session[:guest_user_id] = nil
     guest_user

   end

  # Sets the #traveler class variable
  def get_traveler

    if user_signed_in?
      if session[TRAVELER_USER_SESSION_KEY].blank?
        @traveler = current_user
      else
        @traveler = current_user.travelers.find(session[TRAVELER_USER_SESSION_KEY])
      end 
    else
      # will always be a guest user
      @traveler = current_or_guest_user
    end
  end

  protected

  def create_random_string(length=16)
    SecureRandom.urlsafe_base64(length)
  end
  

  def setup_actions
    @actions = actions
  end

  # Update the session variable
  def set_traveler_id(id)
    session[TRAVELER_USER_SESSION_KEY] = id
  end
  
  private

  # called (once) when the user logs in, insert any code your application needs
  # to hand off from guest_user to current_user.
  def logging_in
    # For example:
    # guest_comments = guest_user.comments.all
    # guest_comments.each do |comment|
      # comment.user_id = current_user.id
      # comment.save!
    # end
  end

  def create_guest_user

    random_string = create_random_string(16)
    u = User.new
    u.first_name = "Visitor"
    u.last_name = "Guest"
    u.password = random_string
    u.email = "guest_#{random_string}@example.com" 
    u.save!(:validate => false)
    session[:guest_user_id] = u.id
    u
  end

  ######################################################################
  #
  # End of Manage guest users
  #
  ######################################################################

end
