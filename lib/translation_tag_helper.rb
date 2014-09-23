module TranslationTagHelper

  def translate_w_tag_as_default tag
  	is_in_tags = I18n.locale == :tags
  	current_default_locale = I18n.default_locale
  	I18n.default_locale = :tags if is_in_tags
    locale_text = I18n.translate(tag.to_sym, default: '[' + tag.to_s + ']')
  	I18n.default_locale = current_default_locale if is_in_tags

  	locale_text
  end

end