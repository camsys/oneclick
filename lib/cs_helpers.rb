module CsHelpers

    ACTION_ICONS = {
        :plan_a_trip => 'icon-share-sign',
        :log_in => 'icon-key',
        :create_an_account => 'icon-edit',
        :identify_places =>'icon-map-marker',
        :travel_profile => 'icon-cogs',
        :previous_trips => 'icon-share-alt icon-flip-horizontal',
        :help_and_support => 'icon-question-sign',
        :find_traveler => 'icon-search',
        :create_traveler =>'icon-user',
        :agents_agencies => 'icon-umbrella',
        :reports => 'icon-bar-chart'
    }

  # TODO Unclear whether this will need to be more flexible depending on how clients want to do their domains
  # may have to vary by environment
  def brand
    Rails.application.config.brand
  end

  def anonymous_user
    User.new
  end

  def assisting?
    session.include? :assisting
  end

  def assisted_user
    Rails.logger.info session[:assisting].ai
    Rails.logger.info @assisted_user.ai
    # TODO This should be a ||=, no?
    User.find_by_id(session[:assisting])
  end

end
