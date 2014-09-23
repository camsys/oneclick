module TranslationTagHelper

  def translate_w_tag_as_default tag
    I18n.translate(tag.to_sym, default: '[' + tag.to_s + ']')
  end

end