module ApplicationHelper

  include CsHelpers

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
        Rails.logger.info "key: #{key} not found: #{e.inspect}"
      end    
    end
  end

  def link_using_locale link_text, locale
    parts = request.fullpath.split('/', 3)
    current_locale = I18n.available_locales.detect do |l|
      parts[1] == l.to_s
    end
    parts.delete_at(1) if current_locale
    parts = parts.join('/')
    parts = '' if parts=='/'
    newpath = "/#{locale}#{parts}"
    if (newpath == request.fullpath) or
      (newpath == "/#{I18n.locale}#{request.fullpath}") or
      (newpath == "/#{I18n.locale}")
      link_text
    else
      link_to link_text, newpath
    end
  end

end
