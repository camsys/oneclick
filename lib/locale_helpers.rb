module LocaleHelpers
  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
    Rails.logger.info "locale is #{I18n.locale}"
  end

  def default_url_options(options={})
    { :locale => ((I18n.locale == I18n.default_locale) ? nil : I18n.locale) }
  end


end