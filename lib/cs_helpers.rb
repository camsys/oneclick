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
    :services => 'fa fa-bus',
    :users => 'fa fa-group',
    :feedback => 'fa fa-thumbs-o-up',
    :sidewalk_obstructions => 'fa fa-comment',
    :stop_assisting => 'fa fa-compass',
    :translations => 'fa fa-language',
    :multi_od_trip => 'fa fa-table'
  }

  def admin_actions
    a = [
      {label: t(:users), target: admin_users_path, icon: ACTION_ICONS[:users], access: :admin_users},
      {label: t(:translations), target: admin_translations_path, icon: ACTION_ICONS[:translations], access: :admin_translations},
    ]
    if Rating.feedback_on?
      a.push({label: t(:feedback), target: ratings_path, icon: ACTION_ICONS[:feedback], access: :admin_feedback})
    end
    if SidewalkObstruction.sidewalk_obstruction_on?
      a.push({label: t(:sidewalk_obstructions), target: admin_sidewalk_obstructions_path, icon: ACTION_ICONS[:sidewalk_obstructions], access: :admin_sidewalk_obstruction})
    end
    a
  end

  def staff_actions
    [
      {label: t(:travelers), target: find_travelers_path, icon: ACTION_ICONS[:find_traveler], access: :staff_travelers},
      {label: t(:agency_profile), target: agency_profile_path, icon: ACTION_ICONS[:find_traveler], access: :show_agency}, #TODO find icon
      {label: t(:provider_profile), target: provider_profile_path, icon: ACTION_ICONS[:find_traveler], access: :show_provider}, #TODO find icon
      {label: t(:trips), target: create_trips_path, icon: ACTION_ICONS[:trips], access: :admin_trips},
      {label: t(:agencies), target: admin_agencies_path, icon: ACTION_ICONS[:agents_agencies], access: :admin_agencies},
      {label: t(:providers), target: admin_providers_path, icon: ACTION_ICONS[:providers], access: :admin_providers},
      {label: t(:services), target: services_path, icon: ACTION_ICONS[:services], access: :admin_services},
      {label: t(:reports), target: admin_reports_path, icon: ACTION_ICONS[:reports], access: :admin_reports},
      {label: t(:multi_od_trip), target: create_multi_od_user_trips_path(current_user), icon: ACTION_ICONS[:multi_od_trip], access: MultiOriginDestTrip}
    ]
  end

  def traveler_actions options = {}
    a = if user_signed_in?
      [
        {label: t(:plan_a_trip), target: new_user_trip_path(get_traveler, locale: I18n.locale), icon: ACTION_ICONS[:plan_a_trip]},
        {label: t(:travel_profile), target: user_path(get_traveler, locale: I18n.locale), icon: ACTION_ICONS[:travel_profile]},
        {label: t(:trips), target: user_trips_path(get_traveler, locale: I18n.locale), icon: ACTION_ICONS[:my_trips]},
        {label: t(:places), target: user_places_path(get_traveler, locale: I18n.locale), icon: ACTION_ICONS[:my_places]},
        {label: t(:stop_assisting), target: unset_traveler_user_trips_path(get_traveler), icon: ACTION_ICONS[:stop_assisting], test: get_traveler != current_or_guest_user}
      ]
    else
      [
        {label: t(:plan_a_trip), target: new_user_trip_path(current_or_guest_user), icon: ACTION_ICONS[:plan_a_trip]},
        {label: t(:log_in), target: new_user_session_path, icon: ACTION_ICONS[:log_in], not_on_homepage: true},
        {label: t(:create_an_account), target: new_user_registration_path, icon: ACTION_ICONS[:create_an_account], not_on_homepage: true}
      ]
    end
    if options[:with_logout]
      a << {label: t(:logout), target: destroy_user_session_path, icon: 'fa-sign-out', divider_before: true, method: :delete}
    end
    a
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
    admin_provider_path(current_user.provider) if current_user.has_role? :provider_staff, :any
  end

  def create_trips_path
    if User.with_role(:provider_staff, :any).include?(current_user)
      admin_provider_trips_path(current_user.provider)
    elsif has_agency_specific_role?
      admin_agency_trips_path(current_user.agency)
    else
      admin_trips_path
    end
  end

  def show_action action
    return true unless action.include? :access
    can? :access, action[:access]
  end

  # Session key for storing the traveler id
  TRAVELER_USER_SESSION_KEY = 'traveler'

  def ui_mode_kiosk?
    CsHelpers::ui_mode_kiosk?
  end

  def self.ui_mode_kiosk?
    Oneclick::Application.config.ui_mode=='kiosk'
  end

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
      formatted_date = I18n.l date.to_date, :format => :oneclick_short
    else
      formatted_date = I18n.l date.to_date, :format => :oneclick_long
    end
    I18n.locale = :tags if is_in_tags

    formatted_date || ""
  end

  def format_time(time)
    is_in_tags = I18n.locale == :tags # tags locale cause trouble in datetime localization, here, using default_locale to localize
    I18n.locale = I18n.default_locale if is_in_tags
    formatted_time = I18n.l time, :format => :oneclick_short unless time.nil?
    I18n.locale = :tags if is_in_tags

    formatted_time || ""
  end


  # Retuens a pseudo-mode for an itinerary. The pseudo-mode is used to determine
  # the correct icon, title, and partial for an itinerary
  def get_pseudomode_for_itinerary(itinerary)
    if itinerary.is_walk
      mode_code = 'walk'
    elsif itinerary.is_car
      mode_code = 'car'
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
      I18n.t(:rail)
    elsif mode_code == 'railbus'
      I18n.t(:rail_and_bus)
    elsif mode_code == 'bus'
      I18n.t(:bus)
    elsif mode_code == 'drivetransit'
      I18n.t(:drive_and_transit)
    elsif mode_code == 'transit'
      I18n.t(:transit)
    elsif mode_code == 'paratransit'
      I18n.t(:mode_paratransit_name)
    elsif mode_code == 'volunteer'
      I18n.t(:volunteer)
    elsif mode_code == 'non-emergency medical service'
      I18n.t(:nemt)
    elsif mode_code == 'nemt'
      I18n.t(:nemt)
    elsif mode_code == 'livery'
      I18n.t(:car_service)
    elsif mode_code == 'taxi'
      I18n.t(:taxi)
    elsif mode_code == 'rideshare'
      I18n.t(:rideshare)
    elsif mode_code == 'walk'
      I18n.t(:walk)
    elsif mode_code == 'car'
      I18n.t(:drive)
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
      if leg.mode.downcase.in? ['rail', 'subway', 'tram', 'bus']
        name_string += leg.agency_id.to_s + " " + leg.mode.to_s.humanize + ' ' + arrow + ' '
      end
    end
    name_string.chop.chop
  end

  # Kiosk-related helpers

  def user_trip_path_for_ui_mode traveler, trip
    unless ui_mode_kiosk?
      user_trip_path traveler, trip, locale: I18n.locale
    else
      kiosk_user_trip_path traveler, trip
    end
  end

  def new_user_characteristic_path_for_ui_mode traveler, options = {}
    unless ui_mode_kiosk?
      new_user_characteristic_path traveler, options
    else
      new_kiosk_user_characteristic_path traveler, options
    end
  end

  def unhide_all_user_trip_part_path_for_ui_mode traveler, trip_part
    unless ui_mode_kiosk?
      unhide_all_user_trip_part_path traveler, trip_part
    else
      unhide_all_kiosk_user_trip_part_path traveler, trip_part
    end
  end

  def new_user_program_path_for_ui_mode traveler, options = {}
    unless ui_mode_kiosk?
      new_user_program_path traveler, options
    else
      new_kiosk_user_program_path traveler, options
    end
  end

  def user_program_path_for_ui_mode traveler, user_programs_proxy_id, options = {}
    unless ui_mode_kiosk?
      user_program_path traveler, user_programs_proxy_id, options
    else
      kiosk_user_program_path traveler, user_programs_proxy_id, options
    end
  end

  def new_user_accommodation_path_for_ui_mode traveler, options = {}
    unless ui_mode_kiosk?
      new_user_accommodation_path traveler, options
    else
      new_kiosk_user_accommodation_path traveler, options
    end
  end

  def skip_user_trip_path_for_ui_mode traveler, current_trip_id
    unless ui_mode_kiosk?
      skip_user_trip_path traveler, current_trip_id
    else
      skip_kiosk_user_trip_path traveler, current_trip_id
    end
  end

  def new_user_trip_characteristic_path_for_ui_mode traveler, trip
    unless ui_mode_kiosk?
      new_user_trip_characteristic_path traveler, trip, locale: I18n.locale
    else
      raise "new_user_trip_characteristic_path not defined for kiosk yet"
    end
  end

  # first check if itinerary service or provider has customized logo
  # then check if it's a walk itinerary, to show walk logo
  # last, just get itineary mode logo
  def logo_url_helper itinerary
    s = itinerary.service
    if s
      if s.logo_url
        return get_service_provider_icon_url(s.logo_url)
      elsif s.provider and s.provider.logo_url
        return get_service_provider_icon_url(s.provider.logo_url)
      end
    end

    if itinerary.is_walk
      asset_path = Mode.walk.logo_url
    elsif itinerary.is_car
      asset_path = Mode.car.logo_url
    else
      asset_path = itinerary.mode.logo_url
    end

    return root_url({locale:''}) + Base.helpers.asset_path(asset_path)
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

  def get_itinerary_cost itinerary
    estimated = false
    fare =  itinerary.cost || (itinerary.service.fare_structures.first rescue nil)
    price_formatted = nil
    cost_in_words = ''
    comments = ''

    if fare.respond_to? :fare_type
      case fare.fare_type
      when FareStructure::FLAT
        if fare.base and fare.rate
          estimated = true
          comments = "+#{number_to_currency(fare.rate)}/mile - " + I18n.t(:cost_estimated)
          fare = fare.base.to_f
          price_formatted = number_to_currency(fare.ceil) + '*'
          cost_in_words = number_to_currency(fare.ceil) + I18n.t(:est)
        elsif fare.base
          fare = fare.base.to_f
          price_formatted = number_to_currency(fare)
          cost_in_words = price_formatted
        else
          fare = nil
        end
      when FareStructure::MILEAGE
        if fare.base
          estimated = true
          comments = "+#{number_to_currency(fare.rate)}/mile - " + I18n.t(:cost_estimated)
          fare = fare.base.to_f
          price_formatted = number_to_currency(fare.ceil) + '*'
          cost_in_words = number_to_currency(fare.ceil) + I18n.t(:est)
        else
          fare = nil
        end
      when FareStructure::COMPLEX
        fare = nil
        estimated = true
        price_formatted = '*'
        comments = I18n.t(:see_details_for_cost)
        cost_in_words = I18n.t(:see_below)
      end
    else
      if itinerary.is_walk or itinerary.is_bicycle #TODO: walk, bicycle currently are put in transit category
        Rails.logger.info 'is walk or bicycle, so no charge'
        fare = 0
        price_formatted = I18n.t(:no_charge)
        cost_in_words = price_formatted
      else
        case itinerary.mode
        when Mode.taxi
          if fare
            fare = fare.ceil
            estimated = true
            price_formatted = number_to_currency(fare) + '*'
            comments = I18n.t(:cost_estimated)
            cost_in_words = number_to_currency(fare) + I18n.t(:est)
          end
        when Mode.rideshare
          fare = nil
          estimated = true
          price_formatted = '*'
          comments = I18n.t(:see_details_for_cost)
          cost_in_words = I18n.t(:see_below)
        end
      end
    end

    if price_formatted.nil?
      unless fare.nil?
        fare = fare.to_f
        if fare == 0
          Rails.logger.info 'no charge as fare is 0'
          price_formatted = I18n.t(:no_charge)
          cost_in_words = price_formatted
        else
          price_formatted = number_to_currency(fare)
          cost_in_words = number_to_currency(fare)
        end
      else
        estimated = true
        price_formatted = '*'
        comments = I18n.t(:see_details_for_cost)
        cost_in_words = I18n.t(:unknown)
      end
    end

    return {price: fare, comments: comments, price_formatted: price_formatted, estimated: estimated, cost_in_words: cost_in_words}
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
    # unless ui_mode_kiosk?
      unselect_all_user_trip_part_path traveler, trip_part
    # else
    #   unselect_all_kiosk_user_trip_part_path traveler, trip_part
    # end
  end
end
