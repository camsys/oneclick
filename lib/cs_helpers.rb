module CsHelpers

  ACTION_ICONS = {
    :plan_a_trip => 'icon-share-sign',
    :log_in => 'icon-key icon-rotate-90',
    :create_an_account => 'icon-edit',
    :identify_places =>'icon-map-marker',
    :travel_profile => 'icon-cogs',
    :my_travel_profile => 'icon-cogs',
    :my_trips => 'icon-share-alt icon-flip-horizontal',
    :my_places => 'icon-map-marker',
    :help_and_support => 'icon-question-sign',
    :find_traveler => 'icon-search',
    :create_traveler =>'icon-user',
    :agents_agencies => 'icon-umbrella',
    :reports => 'icon-bar-chart',
    :trips => 'icon-tags',
    :services => 'icon-bus-sign'
  }
  # Session key for storing the traveler id
  TRAVELER_USER_SESSION_KEY = 'traveler'

  def ui_mode_kiosk?
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

    def actions options = {}
      Rails.logger.info "IN ACTIONS"
      a = if user_signed_in?
        [
          {label: t(:plan_a_trip), target: new_user_trip_path(get_traveler), icon: ACTION_ICONS[:plan_a_trip]},
          {label: t(:my_travel_profile), target: edit_user_registration_path, icon: ACTION_ICONS[:travel_profile]},
          {label: t(:my_trips), target: user_trips_path(get_traveler), icon: ACTION_ICONS[:my_trips]},
          {label: t(:my_places), target: user_places_path(get_traveler), icon: ACTION_ICONS[:my_places]},
        ]
      else
        [
          {label: t(:plan_a_trip), target: new_user_trip_path(current_or_guest_user), icon: ACTION_ICONS[:plan_a_trip]},
          {label: t(:log_in), target: new_user_session_path, icon: ACTION_ICONS[:log_in], not_on_homepage: true},
          {label: t(:create_an_account), target: new_user_registration_path, icon: ACTION_ICONS[:create_an_account], not_on_homepage: true}
        ]
      end
      if options[:with_logout]
        a << {label: t(:logout), target: destroy_user_session_path, icon: 'icon-signout', divider_before: true,
          method: 'delete'}
        #     = link_to , :method=>'delete' do
        # %i.icon.icon-signout
        # = t(:logout)
      end
      Rails.logger.info "ACTIONS about to return #{a.ai}"
      a
    end


  # TODO Unclear whether this will need to be more flexible depending on how clients want to do their domains
  # may have to vary by environment
  def brand
    Rails.application.config.brand
  end

  def assisting?
    session.include? :assisting
  end

  def assisted_user
    @assisted_user ||= User.find_by_id(session[:assisting])
  end

  def format_exception e
    [e.message, e.backtrace].flatten.join("\n")
  end

  # Retuens a pseudo-mode for an itinerary. The pseudo-mode is used to determine
  # the correct icon, title, and partial for an itinerary
  def get_pseudomode_for_itinerary(itinerary)

    if itinerary.is_walk
      mode_name = 'walk'
    elsif itinerary.mode.name.downcase == 'paratransit'
      mode_name = itinerary.service.service_type.name.downcase
    else
      mode_name = itinerary.mode.name.downcase unless itinerary.mode.nil?
    end
    return mode_name    
  end

  # Returns the correct localized title for a trip itinerary
  def get_trip_summary_title(itinerary)
    
    return if itinerary.nil?
    
    mode_name = get_pseudomode_for_itinerary(itinerary)

    if mode_name == 'transit'
      title = I18n.t(:transit)
    elsif mode_name == 'paratransit'
      title = I18n.t(:paratransit)      
    elsif mode_name == 'volunteer'
      title = I18n.t(:volunteer)
    elsif mode_name == 'non-emergency medical service'
      title = I18n.t(:nemt)
    elsif mode_name == 'livery'
      title = I18n.t(:car_service)
    elsif mode_name == 'taxi'
      title = I18n.t(:taxi)      
    elsif mode_name == 'rideshare'
      title = I18n.t(:rideshare)
    elsif mode_name == 'walk'
      title = I18n.t(:walk)
    end
    return title    
  end

  # Kiosk-related helpers

  def user_trip_path_for_ui_mode traveler, trip
    unless ui_mode_kiosk?
      user_trip_path traveler, trip
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

end
