module CsHelpers
  include ActionView::Helpers::NumberHelper
  # include ActionController::Base.helpers.asset_path("logo.jpg", type: :image)
  include ActionController

  ACTION_ICONS = {
    :plan_a_trip => 'fa fa-share-square',
    :log_in => 'fa fa-key fa-rotate-90',
    :create_an_account => 'fa fa-edit',
    :identify_places =>'fa fa-map-marker',
    :travel_profile => 'fa fa-cogs',
    :my_travel_profile => 'fa fa-cogs',
    :my_trips => 'fa fa-share-square fa-flip-horizontal',
    :my_places => 'fa fa-map-marker',
    :help_and_support => 'fa fa-question-sign',
    :find_traveler => 'fa fa-search',
    :agents_agencies => 'fa fa-sitemap',
    :create_agency => 'fa fa-plus-square',
    :providers => 'fa fa-umbrella',
    :reports => 'fa fa-bar-chart-o',
    :trips => 'fa fa-tags',
    :trip_parts => 'fa fa-list-ol',
    :services => 'fa fa-bus',
    :users => 'fa fa-group',
    :feedback => 'fa fa-thumbs-o-up',
    :sidewalk_obstructions => 'fa fa-comment',
    :stop_assisting => 'fa fa-compass',
    :translations => 'fa fa-language',
    :multi_od_trip => 'fa fa-table',
    :user_guide => 'fa fa-book',
    :settings => 'fa fa-gear'
  }

  def admin_actions
    a = [
      {label: TranslationEngine.translate_text(:settings), target: admin_settings_path, icon: ACTION_ICONS[:settings], access: :admin_settings},
      {label: TranslationEngine.translate_text(:users), target: admin_users_path, icon: ACTION_ICONS[:users], access: :admin_users},
      {label: TranslationEngine.translate_text(:translations), target: admin_translations_path, icon: ACTION_ICONS[:translations], access: :admin_translations}
    ]
    if Rating.feedback_on?
      a.push({label: TranslationEngine.translate_text(:feedback), target: feedbacks_path, icon: ACTION_ICONS[:feedback], access: :admin_feedback})
    end
    if SidewalkObstruction.sidewalk_obstruction_on?
      a.push({label: TranslationEngine.translate_text(:sidewalk_obstructions), target: admin_sidewalk_obstructions_path, icon: ACTION_ICONS[:sidewalk_obstructions], access: :admin_sidewalk_obstruction})
    end
    a
  end

  def staff_actions
    [
      {label: TranslationEngine.translate_text(:travelers), target: find_travelers_path, window: "", icon: ACTION_ICONS[:find_traveler], access: :staff_travelers},
      {label: TranslationEngine.translate_text(:agency_profile), target: agency_profile_path, window: "", icon: ACTION_ICONS[:find_traveler], access: :show_agency}, #TODO find icon
      # {label: TranslationEngine.translate_text(:provider_profile), target: provider_profile_path, window: "", icon: ACTION_ICONS[:find_traveler], access: :show_provider}, #TODO find icon
      {label: TranslationEngine.translate_text(:provider_profile), target: provider_profile_path, window: "", icon: ACTION_ICONS[:providers], access: :show_provider}, # New Service Data Screen
      {label: TranslationEngine.translate_text(:trips), target: create_trips_path, window: "", icon: ACTION_ICONS[:trips], access: :admin_trips},
      {label: TranslationEngine.translate_text(:trip_parts), target: create_trip_parts_path, window: "", icon: ACTION_ICONS[:trip_parts], access: :admin_trip_parts},
      {label: TranslationEngine.translate_text(:agencies), target: admin_agencies_path, window: "", icon: ACTION_ICONS[:agents_agencies], access: :admin_agencies},
      {label: TranslationEngine.translate_text(:providers), target: admin_providers_path, window: "", icon: ACTION_ICONS[:providers], access: :admin_providers},
      {label: TranslationEngine.translate_text(:services), target: services_path, window: "", icon: ACTION_ICONS[:services], access: :admin_services},
      {label: TranslationEngine.translate_text(:reports), target: reporting_reports_path, window: "", icon: ACTION_ICONS[:reports], access: :admin_reports},
      {label: TranslationEngine.translate_text(:multi_od_trip), target: create_multi_od_user_trips_path(current_user), window: "", icon: ACTION_ICONS[:multi_od_trip], access: MultiOriginDestTrip},
      {label: TranslationEngine.translate_text(:user_guide), target: Oneclick::Application.config.user_guide_url, window: "_blank", icon: ACTION_ICONS[:user_guide], access: :user_guide}
    ]
  end

  def traveler_actions options = {}
    a = if user_signed_in?
      [
        {label: TranslationEngine.translate_text(:plan_a_trip), target: new_user_trip_path(get_traveler, locale: I18n.locale), icon: ACTION_ICONS[:plan_a_trip]},
        {label: TranslationEngine.translate_text(:travel_profile), target: user_path(get_traveler, locale: I18n.locale), icon: ACTION_ICONS[:travel_profile]},
        {label: TranslationEngine.translate_text(:trips), target: user_trips_path(get_traveler, locale: I18n.locale), icon: ACTION_ICONS[:my_trips]},
        {label: TranslationEngine.translate_text(:places), target: user_places_path(get_traveler, locale: I18n.locale), icon: ACTION_ICONS[:my_places]},
        {label: TranslationEngine.translate_text(:providers), target: providers_path(locale: I18n.locale), icon: ACTION_ICONS[:providers]},
        {label: TranslationEngine.translate_text(:stop_assisting), target: unset_traveler_user_trips_path(get_traveler), icon: ACTION_ICONS[:stop_assisting], test: get_traveler != current_or_guest_user},
        {label: TranslationEngine.translate_text(:feedback), target: '#feedbackModal', icon: 'fa-thumbs-o-up'}
      ]
    else
      [
        {label: TranslationEngine.translate_text(:plan_a_trip), target: new_user_trip_path(current_or_guest_user), icon: ACTION_ICONS[:plan_a_trip]},
        {label: TranslationEngine.translate_text(:log_in), target: new_user_session_path, icon: ACTION_ICONS[:log_in], not_on_homepage: true},
        {label: TranslationEngine.translate_text(:create_an_account), target: new_user_registration_path, icon: ACTION_ICONS[:create_an_account], not_on_homepage: true}
      ]
    end
    if options[:with_logout]
      a << {label: TranslationEngine.translate_text(:logout), target: destroy_user_session_path, icon: 'fa-sign-out', divider_before: true, method: :delete}
    end
    a
  end

  def is_admin
    current_user.has_role?(:admin) or current_user.has_role?(:system_administrator)
  end

  def has_agency_specific_role?
    [:agency_administrator, :agent].any? do |r|
      User.with_role(r, :any).include?(current_user)
    end
  end

  def find_travelers_path
    admin_agency_travelers_path(current_user.agency) if has_agency_specific_role?
  end

  def create_travelers_path
    new_admin_agency_user_path(current_user.agency) if has_agency_specific_role?
  end

  def agency_profile_path
    admin_agency_path(current_user.agency) if has_agency_specific_role?
  end

  def provider_profile_path
    # admin_provider_path(current_user.provider) if current_user.has_role? :provider_staff, :any
    edit_admin_provider_path(current_user.provider) if current_user.has_role? :provider_staff, :any # Path to new service data maintenance screen
  end

  def create_trips_path
    if current_user && current_user.agency
      admin_agency_trips_path(current_user.agency)
    else
      admin_trips_path
    end
  end

  def create_trip_parts_path
    if current_user && current_user.provider
      admin_provider_trip_parts_path(current_user.provider)
    else
      admin_trip_parts_path
    end
  end

  def show_action action
    return true unless action.include? :access
    can? :access, action[:access]
  end

  # Session key for storing the traveler id
  TRAVELER_USER_SESSION_KEY = 'traveler'

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

  def is_admin?
    can? :manage, :all
  end

  # Sets the #traveler class variable
  def get_traveler
    if user_signed_in?
      if session[TRAVELER_USER_SESSION_KEY].blank?
        @traveler = current_user
      else
        # Check among all the users the current_user might impersonate.  First the customers if user is an agent, then travelers if user is a buddy
        if current_user.agency
          begin
            @traveler = current_user.agency.customers.find(session[TRAVELER_USER_SESSION_KEY])
          rescue
            @traveler = current_user.travelers.find(session[TRAVELER_USER_SESSION_KEY])
          end
        else
          @traveler = current_user.travelers.find(session[TRAVELER_USER_SESSION_KEY])
        end
      end
    else
      # will always be a guest user
      @traveler = current_or_guest_user
    end
    @traveler
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

  def api_guest_user
    @cached_guest_user = User.find_by(email: "dedwards8@gmail.com")
  end

  # TODO Unclear whether this will need to be more flexible depending on how clients want to do their domains
  # may have to vary by environment
  def brand
    Rails.application.config.brand
  end

  def assisting?
    session.include? TRAVELER_USER_SESSION_KEY
  end

  def assisted_user
    @assisted_user ||= User.find_by_id(session[TRAVELER_USER_SESSION_KEY])
  end

  def format_exception e
    [e.message, e.backtrace].flatten.join("\n")
  end

  # Standardized date formatter for the app. Use this wherever you need to display a date
  # in the UI. The formatted displays dates as Day of Week, Month Day eg. Tuesday, June 5
  # if the date is from a previous year, the year is appended eg Tuesday, June 5 2012
  def format_date(date)
    if date.nil?
      return ""
    end

    is_in_tags = I18n.locale == :tags # tags locale cause trouble in datetime localization, here, using default_locale to localize
    I18n.locale = I18n.default_locale if is_in_tags
    if date.year == Date.today.year
      formatted_date = TranslationEngine.localize_date_short_format date.to_date
    else
      formatted_date = TranslationEngine.localize_date_long_format date.to_date
    end
    I18n.locale = :tags if is_in_tags

    formatted_date || ""
  end

  def format_time(time)
    is_in_tags = I18n.locale == :tags # tags locale cause trouble in datetime localization, here, using default_locale to localize
    I18n.locale = I18n.default_locale if is_in_tags
    formatted_time = TranslationEngine.localize_time(time) unless time.nil?
    I18n.locale = :tags if is_in_tags

    formatted_time || ""
  end


  # Returns a pseudo-mode for an itinerary. The pseudo-mode is used to determine
  # the correct icon, title, and partial for an itinerary
  def get_pseudomode_for_itinerary(itinerary)
    if itinerary.is_walk
      mode_code = 'walk'
    elsif itinerary.is_car
      mode_code = 'car'
    elsif itinerary.is_bicycle
      mode_code = 'bicycle'
    elsif itinerary.mode.code == 'mode_paratransit'
      mode_code = itinerary.service.service_type.code.downcase
    elsif itinerary.mode.code == 'mode_transit'
      mode_code = itinerary.transit_type
    else
      mode_code = itinerary.mode.code.gsub(/^mode_/, '') rescue 'UNKNOWN'
    end
    return mode_code
  end

  # Returns the correct localized title for a trip itinerary
  def get_trip_summary_title(itinerary)

    return if itinerary.nil?

    mode_code = get_pseudomode_for_itinerary(itinerary)
    title = if mode_code == 'rail'
      TranslationEngine.translate_text(:rail)
    elsif mode_code == 'railbus'
      TranslationEngine.translate_text(:rail_and_bus)
    elsif mode_code == 'bus'
      TranslationEngine.translate_text(:bus)
    elsif mode_code == 'drivetransit'
      TranslationEngine.translate_text(:drive_and_transit)
    elsif mode_code == 'transit'
      TranslationEngine.translate_text(:transit)
    elsif mode_code == 'paratransit'
      TranslationEngine.translate_text(:mode_paratransit_name)
    elsif mode_code == 'volunteer'
      TranslationEngine.translate_text(:volunteer)
    elsif mode_code == 'non-emergency medical service'
      TranslationEngine.translate_text(:nemt)
    elsif mode_code == 'nemt'
      TranslationEngine.translate_text(:nemt)
    elsif mode_code == 'dial_a_ride'
      TranslationEngine.translate_text(:dial_a_ride)
    elsif mode_code == 'tap'
      TranslationEngine.translate_text(:tap)
    elsif mode_code == 'livery'
      TranslationEngine.translate_text(:car_service)
    elsif mode_code == 'taxi'
      TranslationEngine.translate_text(:taxi)
    elsif mode_code == 'rideshare'
      TranslationEngine.translate_text(:rideshare)
    elsif mode_code == 'walk'
      TranslationEngine.translate_text(:walk)
    elsif mode_code == 'car'
      TranslationEngine.translate_text(:drive)
    elsif mode_code == 'bicycle'
      TranslationEngine.translate_text(:bicycle)
    elsif mode_code == 'ride_hailing'
      TranslationEngine.translate_text(:ride_hailing)
    end
    return title
  end

  #Generates a transit name of the form AGENCY MODE, AGENCY MODE e.g., MARTA Bus, MARTA Subway, CCT Bus
  def get_trip_summary_name(itinerary)

    return if itinerary.nil?

    return itinerary.service.name if itinerary.service

    return get_trip_summary_title(itinerary) unless itinerary.mode.code == 'mode_transit'

    name_string = ""
    legs = itinerary.get_legs
    arrow = "\u2023"
    legs.each do |leg|
      if leg.mode.in? Leg::TransitLeg::TRANSIT_LEGS
        name_string += leg.agency_id.to_s + " " + leg.mode.to_s.humanize + ' ' + arrow + ' '
      end
    end
    name_string.chop.chop
  end

  # first check if itinerary service or provider has customized logo
  # then check if it's a walk itinerary, to show walk logo
  # last, just get itineary mode logo
  def logo_url_helper itinerary
    s = itinerary.service
    if s
      if s.taxi_fare_finder_city.present?
        return ActionController::Base.helpers.asset_path("tff_logo_50.jpg")
      elsif s.logo_url
        return get_service_provider_icon_url(s.logo_url)
      elsif s.provider and s.provider.logo_url
        return get_service_provider_icon_url(s.provider.logo_url)
      end
    end

    if itinerary.is_walk
      asset_path = Mode.walk.logo_url
    elsif itinerary.is_car
      asset_path = Mode.car.logo_url
    elsif itinerary.is_bicycle
      asset_path = Mode.bicycle.logo_url
    else
      asset_path = itinerary.mode.logo_url
    end

    return asset_path
  end

  # logos are stored in local file system under dev environment
  # stored in AWS s3 under other environments
  def get_service_provider_icon_url(raw_logo_url)
    case ENV["RAILS_ENV"]
    when 'production', 'qa', 'integration'
      return raw_logo_url
    else
      return root_url({locale:''}) + Base.helpers.asset_path(raw_logo_url)
    end
  end

  def get_itinerary_start_time itinerary
    tp = itinerary.trip_part
    case itinerary.mode
    when Mode.taxi
      tp.is_depart ? tp.trip_time : (tp.trip_time - itinerary.duration.seconds)
    else
      itinerary.start_time
    end
  end

  def get_itinerary_end_time itinerary
    tp = itinerary.trip_part
    case itinerary.mode
    when Mode.taxi
      tp.is_depart ? (tp.trip_time + itinerary.duration.seconds) : tp.trip_time
    else
      itinerary.end_time
    end
  end

  def unselect_all_user_trip_part_path_for_ui_mode traveler, trip_part
        unselect_all_user_trip_part_path traveler, trip_part
  end

end
