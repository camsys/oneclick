module ApplicationHelper

  METERS_TO_MILES = 0.000621371192
  MILE_TO_FEET = 5280

  include CsHelpers
  include LocaleHelpers

  KIOSK_ICON_DICTIONARY = {
    Leg::TripLeg::WALK => 'travelcon-walk',
    Leg::TripLeg::TRAM => 'travelcon-subway',
    Leg::TripLeg::SUBWAY => 'travelcon-subway',
    Leg::TripLeg::RAIL => 'travelcon-rail',
    Leg::TripLeg::BUS => 'travelcon-bus',
    Leg::TripLeg::FERRY => 'travelcon-boat',
    Leg::TripLeg::CAR => 'travelcon-car',
    Leg::TripLeg::BICYCLE => 'travelcon-bicycle'
  }

  # Returns the name of the logo image based on the oneclick configuration
  def get_logo
    return Oneclick::Application.config.ui_logo
  end

  def get_logo_path
    return get_logo
  end

  def get_logo_text
    return Oneclick::Application.config.logo_text
  end

  # Returns a mode-specific icon
  def get_mode_icon(mode)
    if ENV['UI_MODE']=='kiosk'
      KIOSK_ICON_DICTIONARY.default = 'travelcon-bus'
      KIOSK_ICON_DICTIONARY[mode]
    else
      puts mode.downcase
      Mode.where(code: 'mode_' + mode.downcase).first.logo_url
    end
  end

  # Returns a service-specific icon
  def get_service_provider_icon(agency_id, mode)
    # search name first, then search external_id
    # this is because leg.agency_id is pre-processed in itinerary_parser
    # in which agency_id was not original agency_id from GTFS
    # but instead it's identified service name...
    s = Service.where(name: agency_id).first ||
      Service.where(external_id: agency_id).first

    if s
      if s.logo_url
        return get_service_provider_icon_url(s.logo_url)
      elsif s.provider and s.provider.logo_url
        return get_service_provider_icon_url(s.provider.logo_url)
      end
    end

    return get_mode_icon(mode)
  end

  # Formats a line in the itinerary
  def format_email_itinerary_item(&block)

    # Check to see if there is any content in the block
    content = capture(&block)
    if content.nil?
      content = "&nbsp;"
    end
    html << content
    return html.html_safe
  end

  # Defines an array of filter options for the MyTrips page. The filters combine date range filters
  # with trip purpose filters. To make sure we can identify which is which, we simply add a constant (100)
  # to the time filter id. This assumes thata there are no more than 99 trip purposes
  #
  # The TimeFilterHelper is localized so strings are properly translated
  def trip_filters
    elems = []
    TimeFilterHelper.time_filters.each do |tf|
      elems << {
        :id => 100 + tf[:id],
        :value => tf[:value]
      }
    end
    TripPurpose.all.each do |tp|
      elems << {
        :id => tp.id,
        :value => t(tp.name)
      }
    end
    return elems
  end


  # Returns true if the current user is assisting the traveler, false if the current
  # user is the current traveler
  def is_assisting
    unless current_user
      return false
    end
    if @traveler
      return @traveler.id == current_or_guest_user.id ? false : true
    else
      return false
    end
  end

  def exact_distance_to_words(dist_in_meters)
    return '' unless dist_in_meters

    # convert the meters to miles
    miles = dist_in_meters * METERS_TO_MILES
    if miles < 0.001
      dist_str = [miles.round(4).to_s, I18n.t(:miles)].join(' ')
    elsif miles < 0.01
      dist_str = [miles.round(3).to_s, I18n.t(:miles)].join(' ')
    else
      dist_str = [miles.round(2).to_s, I18n.t(:miles)].join(' ')
    end

    dist_str
  end

  def distance_to_words(dist_in_meters)
    return t(:n_a) unless dist_in_meters

    # convert the meters to miles
    miles = dist_in_meters * METERS_TO_MILES
    if miles < 0.25
      dist_str = t(:less_than_1_block)
    elsif miles < 0.5
      dist_str = t(:about_2_blocks)
    elsif miles < 1
      dist_str = t(:about_4_blocks)
    else
      dist_str = t(:twof_miles) % [miles]
    end
    dist_str
  end

  def duration_to_words(time_in_seconds, options = {})
    return t(:n_a) unless time_in_seconds

    time_in_seconds = time_in_seconds.to_i
    hours = time_in_seconds/3600
    minutes = (time_in_seconds - (hours * 3600))/60

    time_string = ''

    if time_in_seconds > 60*60*24 and options[:days_only]
      return I18n.translate(:day, count: hours / 24)
    end

    if hours > 0
      format = ((options[:suppress_minutes] and minutes==0) ? :hour_long : :hour)
      time_string << I18n.translate(format, count: hours)  + ' '
    end

    if minutes > 0 || (hours > 0 and !options[:suppress_minutes])
      time_string << I18n.translate(:minute, count: minutes)
    end

    if time_in_seconds < 60
      time_string = I18n.translate(:less_than_one_minute)
    end

    if options[:days_only]
      time_string = I18n.translate(:day, count: hours/24.round)
    end

    time_string
  end

  def day_range_to_words(start_time_in_seconds, end_time_in_seconds)
    return t(:n_a) unless (
      start_time_in_seconds && end_time_in_seconds && 
      (end_time_in_seconds >= start_time_in_seconds)
    )

    start_days = start_time_in_seconds/3600/24.round
    end_days = end_time_in_seconds/3600/24.round

    start_days.to_s + " " + I18n.translate(:to).downcase + " " + I18n.translate(:day, count: end_days)
  end

  def get_boolean(val)
    if val
      return "<i class='fa-check'></i>".html_safe
    end
    #return val.nil? ? 'N' : val == true ? 'Y' : 'N'
  end

  def format_date_time(datetime)
    is_in_tags = I18n.locale == :tags # tags locale cause trouble in datetime localization, here, using default_locale to localize
    I18n.locale = I18n.default_locale if is_in_tags
    formatted_date_time = l datetime, :format => :long unless datetime.nil?
    I18n.locale = :tags if is_in_tags

    formatted_date_time || ""
  end

  # TODO These next 2 methods are very similar to methods in CsHelper,should possible be consolidated
  # Returns the correct partial for a trip itinerary
  def get_trip_partial(itinerary)

    return if itinerary.nil?

    mode_code = get_pseudomode_for_itinerary(itinerary)
    #is this not a switch case?  Saves a few evaluations that way...
    partial = if mode_code.in? ['transit', 'rail', 'bus', 'railbus', 'drivetransit']
      'transit_details'
    elsif mode_code == 'paratransit'
      'paratransit_details'
    elsif mode_code == 'volunteer'
      'paratransit_details'
    elsif mode_code == 'non-emergency medical service'
      'paratransit_details'
    elsif mode_code == 'nemt'
      'paratransit_details'
    elsif mode_code == 'livery'
      'paratransit_details'
    elsif mode_code == 'taxi'
      'taxi_details'
    elsif mode_code == 'rideshare'
      'rideshare_details'
    elsif mode_code == 'walk'
      'walk_details'
    elsif mode_code == 'car'
      'car_details'
    elsif mode_code == 'bicycle'
      'bicycle_details'
    end
    return partial
  end

  # Returns the correct localized title for a trip itinerary
  # NOTE: this function is not being actively used as we now use client-uploaded icons
  def get_trip_summary_icon(itinerary)
    return if itinerary.nil?

    fa_prefix = ui_mode_kiosk? ? 'icon' : 'fa'

    mode_code = get_pseudomode_for_itinerary(itinerary)
    icon_name = if mode_code == 'rail'
      'icon-bus-sign'
    elsif mode_code == 'railbus'
      'icon-bus-sign'
    elsif mode_code == 'bus'
      'icon-bus-sign'
    elsif mode_code == 'transit'
      'icon-bus-sign'
    elsif mode_code == 'paratransit'
      "#{fa_prefix}-truck"
    elsif mode_code == 'volunteer'
      "#{fa_prefix}-truck"
    elsif mode_code == 'nemt'
      "#{fa_prefix}-truck"
    elsif mode_code == 'non-emergency medical service'
      "#{fa_prefix}-truck"
    elsif mode_code == 'livery'
      'icon-taxi-sign'
    elsif mode_code == 'taxi'
      'icon-taxi-sign'
    elsif mode_code == 'rideshare'
      "#{fa_prefix}-group"
    elsif mode_code == 'walk'
      'icon-walking-sign'
    elsif mode_code == 'drivetransit'
      'icon-bus-sign'
    elsif mode_code == 'car'
      'auto'
    elsif mode_code == 'bicycle'
      'icon-bike-sign'
    end
    return icon_name
  end

  def get_trip_direction_icon(itin_or_trip)
    (itin_or_trip.is_return_trip ? 'fa-arrow-left' : 'fa-arrow-right')
  end

  def display_base_errors resource
    return '' if (resource.errors.empty?) or (resource.errors[:base].empty?)
    messages = resource.errors[:base].map { |msg| content_tag(:p, msg) }.join
    html = <<-HTML
    <div class="alert alert-danger alert-block">
      <button type="button" class="close" data-dismiss="alert">&#215;</button>
      #{messages}
    </div>
    HTML
    html.html_safe
  end

  def t(key, options={})
    branded_key = [brand, key].join('.')
    if I18n.locale != :tags
      begin
        if I18n.translate(branded_key, options.merge({raise: true})).class != Array
          make_translation_safe(I18n.translate(branded_key, options.merge({raise: true})))
        else
          raw(I18n.translate(branded_key, options.merge({raise: true})))
        end
      rescue Exception => e
        begin
          if I18n.translate(key, options.merge({raise: true})).class != Array
            make_translation_safe(I18n.translate(key, options.merge({raise: true})))
          else
            raw(I18n.translate(key, options.merge({raise: true})))
          end
        rescue Exception => e
          Rails.logger.warn "key: #{key} not found: #{e.inspect}"
          begin
            if I18n.translate(key,options.merge({raise: true, locale: I18n.default_locale})).class != Array
              make_translation_safe(I18n.translate(key,options.merge({raise: true, locale: I18n.default_locale})))
            else
              raw(I18n.translate(key,options.merge({raise: true, locale: I18n.default_locale})))
            end
          rescue Exception => e
            "Key not found: #{key}" # No need to internationalize this.  Should only hit if a non-existant key is called
          end
        end
      end
    else
      begin
        if I18n.translate(branded_key, options.merge({raise: true, locale: I18n.default_locale})).class != Array
          make_translation_safe(I18n.translate(branded_key, options.merge({raise: true, locale: I18n.default_locale})))
        else
          raw(I18n.translate(branded_key, options.merge({raise: true, locale: I18n.default_locale})))
        end
      rescue Exception => e
        return '[' + key.to_s + ']'
      end

      return '[' + branded_key.to_s + ']'
    end
  end

  def make_translation_safe(translation)
    translation.to_s.gsub('%{application_name}', Oneclick::Application.config.name).gsub('%{break}', '</br> ').html_safe
  end

  def links_to_each_locale(show_translations = false)
    links = []
    I18n.available_locales.each do |l|
      links << link_using_locale(I18n.t("locales.#{l}"), l)
    end
    if show_translations
      links << link_using_locale(Oneclick::Application::config.translation_tag_locale_text, :tags)
    end

    return '' if links.size <= 1

    links.join(' | ').html_safe
  end

  def link_using_locale link_text, locale
    path = session[:location] || request.fullpath
    parts = path.split('/', 3)

    current_locale = I18n.available_locales.detect do |l|
      parts[1] == l.to_s
    end
    parts.delete_at(1) if current_locale or I18n.locale == :tags
    parts = parts.join('/')
    parts = '' if parts=='/'
    newpath = "/#{locale}#{parts}"

    if (newpath == path) or
      (newpath == "/#{I18n.locale}#{path}") or
      (newpath == "/#{I18n.locale}")
      link_text
    else
      link_to link_text, newpath
    end
  end

  def link_without_locale link_text
    parts = link_text.split('/', 3)
    has_locale = I18n.available_locales.detect do |l|
      parts[1] == l.to_s
    end
    parts.delete_at(1) if has_locale
    parts = parts.join('/')
    return '/' if parts.empty?
    parts
  end

  def at_root
    (request.path == root_path) or
    (link_without_locale(request.path) == root_path)
  end

  # Allow controller to override what controller css class they want to use
  def controller_css_class
    controller_name
  end

  def controller_and_action
    (controller.controller_name + controller.action_name.capitalize).underscore
  end

  def tel_link text_num
    real_num = text_num.downcase.tr('a-z','22233344455566677778889')

    if real_num =~ /([0-9]{3})-([0-9]{3})-([0-9]{4})/
      link_to text_num, "tel://+1#{$1}#{$2}#{$3}"
    else
      text_num
    end
  end

  # non-tag locale: the key must be defined, and content is not blank
  # tag locale: key must be defined
  def whether_show_tranlatation_item? key
    defined? key and
    !Translation.where(key: key).first.nil? and
    (I18n.locale == :tags or !Translation.where(key: key, locale: I18n.locale).first.nil?) and
    !I18n.t(key).blank?
  end

  def translation_exists?(key_str)
    translation = I18n.t key_str, :raise => true rescue false
    if translation
      return !translation.empty?
    else
      return false
    end
  end

  def add_tooltip(key)
    if translation_exists?(key)
      html = '<i class="fa fa-question-circle fa-2x pull-right label-help" style="margin-top:-4px;" title data-original-title="'
      html << t(key.to_sym)
      html << '" aria-label="'
      html << t(key.to_sym)
      html << '" tabindex="0"></i>'
      return html.html_safe
    end
  end

  def print_messages(obj)
    html = '<strong>Please correct the problems below:</strong></br>'
    line_break = '</br>'.html_safe
    obj.object.nil? ? '' : html << obj.object.errors.full_messages.uniq.join(". #{line_break}")
    return html.html_safe
  end

end
