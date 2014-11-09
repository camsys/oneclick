module LocaleHelpers
  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
    Rails.logger.debug "locale is #{I18n.locale}"
  end

  def default_url_options(options={})
    { :locale => ((I18n.locale == I18n.default_locale) ? nil : I18n.locale) }
  end


  def cms_snippet_content(key)
    { :locale => ((I18n.locale == I18n.default_locale) ? nil : I18n.locale) }
    out = translate(key)
     return (out.to_str.include? 'class="translation_missing"') ? "" : out   # (link_to "Define #{key}", new_translation_path(:key => key, :locale => I18n.locale)).html_safe
  end

  # return name value pairs suitable for passing to simple_form collection
  def form_collection_from_relation(include_all, relation, translate=true, mark_inactive=false)
    if include_all
      list = [[I18n.t(:all), -1]]
    else
      list = []
    end
    inactive_label = " (#{I18n.t(:inactive)})"
    relation.each do |r|
      name = "#{(translate ? I18n.t(r.name) : r.name)}#{mark_inactive && !r.active ? inactive_label : ''}"
      list << [name, r.id]
    end
    list
  end

end
