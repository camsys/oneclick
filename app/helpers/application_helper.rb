module ApplicationHelper

  include CsHelpers

  def format_date_time(datetime)
    return datetime.strftime("%I:%M %p %b %d %Y") unless datetime.nil?
  end
  def format_date(date)
    return date.strftime("%b %d %Y") unless date.nil?
  end
  def format_time(time)
    return time.strftime("%I:%M") unless time.nil?
  end

  def get_trip_summary_title(mode)
    if mode == 'transit'
      title = t(:transit)
    elsif mode == 'paratransit'
      title = t(:paratransit)      
    elsif mode == 'taxi'
      title = t(:taxi)      
    end
    return title    
  end
  def get_trip_summary_icon(mode) 
    if mode == 'transit'
      icon_name = 'icon-bus-sign'
    elsif mode == 'paratransit'
      icon_name = 'icon-truck-sign'      
    elsif mode == 'taxi'
      icon_name = 'icon-taxi-sign'      
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
