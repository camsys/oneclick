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
    :reports => 'icon-bar-chart'
  }

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

    def actions options = {}
      a = if user_signed_in?
        # if current_user.has_role? :admin
        #   [
        #     {label: t(:find_traveler), target: error_501_path, icon: ACTION_ICONS[:find_traveler]},
        #     {label: t(:create_traveler), target: error_501_path, icon: ACTION_ICONS[:create_traveler]},
        #     {label: t(:agents_agencies), target: error_501_path, icon: ACTION_ICONS[:agents_agencies]},
        #     {label: t(:reports), target: admin_reports_path, icon: ACTION_ICONS[:reports]},
        #   ]          
        # else
          [
            {label: t(:plan_a_trip), target: new_user_trip_path(@traveler), icon: ACTION_ICONS[:plan_a_trip]},
            {label: t(:my_travel_profile), target: edit_user_registration_path, icon: ACTION_ICONS[:travel_profile]},
            {label: t(:my_trips), target: user_trips_path(@traveler), icon: ACTION_ICONS[:my_trips]},
            {label: t(:my_places), target: user_trips_path(@traveler), icon: ACTION_ICONS[:my_places]},
          ]
        # end
      else
        [
          {label: t(:plan_a_trip), target: new_user_trip_path(current_or_guest_user), icon: ACTION_ICONS[:plan_a_trip]},
          {label: t(:log_in), target: new_user_session_path, icon: ACTION_ICONS[:log_in]},
          {label: t(:create_an_account), target: new_user_registration_path, icon: ACTION_ICONS[:create_an_account]}
        ]
      end
      if options[:with_logout]
        a << {label: t(:logout), target: destroy_user_session_path, icon: 'icon-signout', divider_before: true,
          method: 'delete'}
                      #     = link_to , :method=>'delete' do
                      # %i.icon.icon-signout
                      # = t(:logout)
                    end
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
end
