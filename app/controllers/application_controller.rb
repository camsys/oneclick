class ApplicationController < ActionController::Base
  include CsHelpers

  # acts_as_token_authentication_handler_for User
  force_ssl if: :ssl_configured?

  def ssl_configured?
    ENV["ENABLE_HTTPS"] == "true"
  end

  # include the helper method in any controller which needs to know about guest users
  helper_method :current_or_guest_user
  helper_method :mobile?

  protect_from_forgery
  before_filter :get_traveler
  before_filter :set_locale
  before_filter :setup_actions
  before_filter :get_unread_messages
  before_filter :set_feedback_types
  before_action do |controller|
    @current_ability ||= Ability.new(get_traveler)
  end
  after_filter :clear_location

  rescue_from CanCan::AccessDenied do |exception|
    if current_user.nil?
      if I18n.locale == :tags
        # non-admin users trying to access tags page will be redirected to trip planning page in default locale
        redirect_to root_path(locale: I18n.default_locale)
      else
        redirect_to new_user_session_path + '?redirect_to=' + request.original_url.sub('&','%26'), :alert => exception.message
      end
    else
      redirect_to root_path, :alert => exception.message
    end
  end

  def get_unread_messages
    @unread_messages = current_user.try(:unread_received_messages) if current_user
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

  def default_url_options(options={}) # This overrides/extends
    { locale: I18n.locale }
  end

  def clear_location
    session.delete :location
  end

  def start_assisting user
    set_traveler_id user.id
    @current_ability = nil
  end

  def stop_assisting
    session.delete TRAVELER_USER_SESSION_KEY
    @current_ability = nil
  end

  def set_no_cache
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end

  def redirect_to(options = {}, response_status = {})
    options[:locale] = I18n.locale if options.is_a? Hash
    super(options, response_status)
  end

  def set_feedback_types
    @feedback_types = []
    app = FeedbackType.find_by(name: 'application')
    trip = FeedbackType.find_by(name: 'trip')
    unmet_need = FeedbackType.find_by(name: 'unmet_need')

    app_feedback = [TranslationEngine.translate_text(app.name.to_sym), app.id] if app
    trip_feedback = [TranslationEngine.translate_text(trip.name.to_sym), trip.id] if trip
    unmet_need_feedback = [TranslationEngine.translate_text(unmet_need.name.to_sym), unmet_need.id] if unmet_need

    @feedback_types << app_feedback

    if params[:controller] == "trips" && params[:action] == "show"
      @feedback_types << unmet_need_feedback
    elsif params[:controller] == "trips" && params[:action] == "plan"
      @feedback_types << trip_feedback
      @feedback_types << unmet_need_feedback
    elsif params[:controller] == "admin/trips" && params[:action] == "index"
      @feedback_types << trip_feedback
      @feedback_types << unmet_need_feedback
    end
  end

  protected

  def create_random_string(length=16)
    SecureRandom.urlsafe_base64(length)
  end


  def setup_actions
    @actions = traveler_actions
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
      root_path(locale: current_or_guest_user.preferred_locale)
    end
  end

  def content
  end

  private

  def mobile?
    unless request.user_agent.nil?
      request.user_agent.downcase =~ /mobile|android|touch|webos|hpwos/
    end
  end

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
