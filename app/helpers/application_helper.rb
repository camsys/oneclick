module ApplicationHelper

  METERS_TO_MILES = 0.000621371192

  include CsHelpers
  include LocaleHelpers
  
  ICON_DICTIONARY = {
      TripLeg::WALK => 'travelcon-walk',
      TripLeg::TRAM => 'travelcon-subway',
      TripLeg::SUBWAY => 'travelcon-subway',
      TripLeg::RAIL => 'travelcon-rail',
      TripLeg::BUS => 'travelcon-bus',
      TripLeg::FERRY => 'travelcon-boat',
      TripLeg::CAR => 'travelcon-car'
      }

  # Returns the name of the logo image based on the oneclick configuration
  def get_logo
    return Oneclick::Application.config.ui_logo
  end

  # Returns a mode-specific icon
  def get_mode_icon(mode)
    ICON_DICTIONARY.default = 'travelcon-bus'
    ICON_DICTIONARY[mode]
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
        :value => tp
      }
    end
    return elems
  end

  # Returns a set of rating icons as a span
  def get_rating_icons(trip, size=1)
    rating = trip.get_rating
    html = "<span id='stars'>"
    for i in 1..5
      link = rate_rating_url(trip, :user_id => trip.user.id, :stars => i, :size => size)
      html << "<a title='Rate " + i.to_s + " Stars' href=" + link + " style='color: black; text-decoration: none' data-method='post' data-remote='true'><i id=star" + trip.id.to_s + '_' + i.to_s + " class='fa fa-" + size.to_s
      if i <= rating
        html << "x fa-star'> </i></a>"
      else
        html << "x fa-star-o'> </i></a>"
      end
    end
    html << "</span>"
    return html.html_safe
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

    time_string
  end

  def get_boolean(val)
    if val
      return "<i class='fa-check'></i>".html_safe
    end
    #return val.nil? ? 'N' : val == true ? 'Y' : 'N'
  end

  def format_date_time(datetime)
    return l datetime, :format => :long unless datetime.nil?
  end

  # Standardized date formatter for the app. Use this wherever you need to display a date
  # in the UI. The formatted displays dates as Day of Week, Month Day eg. Tuesday, June 5
  # if the date is from a previous year, the year is appended eg Tuesday, June 5 2012
  def format_date(date)
    if date.nil?
      return ""
    end
    if date.year == Date.today.year
      return l date.to_date, :format => :oneclick_short unless date.nil?
    else
      return l date.to_date, :format => :oneclick_long unless date.nil?
    end
  end

  def format_time(time)
    return l time, :format => :oneclick_short unless time.nil?
  end

  # TODO These next 2 methods are very similar to methods in CsHelper,should possible be consolidated
  # Returns the correct partial for a trip itinerary
  def get_trip_partial(itinerary)

    return if itinerary.nil?
    
    mode_code = get_pseudomode_for_itinerary(itinerary)

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
    end
    return partial
  end

  # Returns the correct localized title for a trip itinerary
  def get_trip_summary_icon(itinerary)
    return if itinerary.nil?
    
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
      'fa-truck'
    elsif mode_code == 'volunteer'
      'fa-truck'
    elsif mode_code == 'nemt'
      'fa-truck'
    elsif mode_code == 'non-emergency medical service'
      'fa-truck'
    elsif mode_code == 'livery'
      'icon-taxi-sign'
    elsif mode_code == 'taxi'
      'icon-taxi-sign'      
    elsif mode_code == 'rideshare'
      'fa-group'      
    elsif mode_code == 'walk'
      'icon-accessibility-sign'
    elsif mode_code == 'drivetransit'
      'icon-bus-sign'
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
    begin
      I18n.translate(branded_key, options.merge({raise: true}))
    rescue Exception => e
      begin
        I18n.translate(key, options.merge({raise: true}))
      rescue Exception => e
        Rails.logger.info "key: #{key} not found: #{e.inspect}"
        # Note we swallow the exception
      end
    end
  end

  def link_using_locale link_text, locale
    path = session[:location] || request.fullpath
    parts = path.split('/', 3)
    current_locale = I18n.available_locales.detect do |l|
      parts[1] == l.to_s
    end
    parts.delete_at(1) if current_locale
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

  def tel_link num
    if num =~ /([0-9]{3})-([0-9]{3})-([0-9]{4})/
      link_to num, "tel://+1#{$1}#{$2}#{$3}"
    else
      num
    end
  end
end
