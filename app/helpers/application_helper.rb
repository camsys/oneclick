module ApplicationHelper

  METERS_TO_MILES = 0.000621371192
  
  include CsHelpers

  def is_traveler
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
  
  def duration_to_words(time_in_seconds)
    
    return t(:n_a) unless time_in_seconds

    time_in_seconds = time_in_seconds.to_i
    hours = time_in_seconds/3600
    minutes = (time_in_seconds - (hours * 3600))/60

    time_string = ''
    if hours > 0
      time_string << I18n.translate(:hour, count: hours)  + ' '
    end

    if minutes > 0 || hours > 0
      time_string << I18n.translate(:minute, count: minutes)
    end

    if time_in_seconds < 60
      time_string = I18n.translate(:less_than_one_minute)
    end

    time_string
  end

  def get_boolean(val)
    if val
      return "<i class='icon-ok'></i>".html_safe
    end
    #return val.nil? ? 'N' : val == true ? 'Y' : 'N'
  end

  def format_date_time(datetime)
    return datetime.strftime("%-I:%M %p %A, %B %-d %Y") unless datetime.nil?
  end
  def format_date(date)
    return date.strftime("%A, %B %-d %Y") unless date.nil?
  end
  def format_time(time)
    return time.strftime("%-I:%M") unless time.nil?
  end

  def get_trip_summary_title(mode)
    return if mode.nil?
    
    if mode.name.downcase == 'transit'
      title = t(:transit)
    elsif mode.name.downcase == 'paratransit'
      title = t(:paratransit)      
    elsif mode.name.downcase == 'taxi'
      title = t(:taxi)      
    elsif mode == 'rideshare'
      title = t(:rideshare)
    end
    return title    
  end

  def get_trip_summary_icon(mode) 
    return if mode.nil?

    if mode.name.downcase == 'transit'
      icon_name = 'icon-bus-sign'
    elsif mode.name.downcase == 'paratransit'
      icon_name = 'icon-truck-sign'      
    elsif mode.name.downcase == 'taxi'
      icon_name = 'icon-taxi-sign'      
    elsif mode == 'rideshare'
      icon_name = 'icon-group'      
    end
    return icon_name
  end
  
  def display_base_errors resource
    return '' if (resource.errors.empty?) or (resource.errors[:base].empty?)
    messages = resource.errors[:base].map { |msg| content_tag(:p, msg) }.join
    html = <<-HTML
    <div class="alert alert-error alert-block">
      <button type="button" class="close" data-dismiss="alert">&#215;</button>
      #{messages}
    </div>
    HTML
    html.html_safe
  end

  def t(key, options={})
    branded_key = [brand, key].join('.')
    begin
      translate(branded_key, options.merge({raise: true}))
    rescue Exception => e
      begin
        translate(key, options.merge({raise: true}))
      rescue Exception => e
        # Rails.logger.info "key: #{key} not found: #{e.inspect}"
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

end
