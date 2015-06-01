module ServicesHelper
  def sanitize_nil_to_na input
    input.nil? ? TranslationEngine.translate_text(:not_available) : input
  end
end