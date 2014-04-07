class ApplicationController < ActionController::Base
  include CsHelpers
  include LocaleHelpers

  # acts_as_token_authentication_handler_for User

  # include the helper method in any controller which needs to know about guest users
  helper_method :current_or_guest_user

  protect_from_forgery
  before_filter :get_traveler
  before_filter :set_locale
  before_filter :setup_actions
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

  def set_locale
    if params[:locale]
       I18n.locale = params[:locale]
    else
      I18n.locale = current_or_guest_user.preferred_locale
    end
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

  def after_sign_in_path_for(resource)
    if session[:agency]
      return new_user_registration_path(locale: current_or_guest_user.preferred_locale)
    end
    if session[:inline]
      get_traveler
      unless Trip.where(id: session[:current_trip_id]).exists?
        session[:current_trip_id] =  nil
        return new_user_trip_path(current_or_guest_user, locale: current_or_guest_user.preferred_locale)
      end
      @trip = Trip.find(session[:current_trip_id])
      session[:current_trip_id] =  nil
      @trip.create_itineraries
      user_trip_path(@traveler, @trip)
    else
      if ui_mode_kiosk?
        new_user_trip_path(current_or_guest_user)
      else
        root_path(locale: current_or_guest_user.preferred_locale)
      end
    end
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
    u.add_role :anonymous_traveler
    session[:guest_user_id] = u.id
    u
  end

  ######################################################################
  #
  # End of Manage guest users
  #
  ######################################################################

end
