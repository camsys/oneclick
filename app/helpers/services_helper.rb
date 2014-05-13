module ServicesHelper
  def sanitize_nil_to_na input
    input.nil? ? t(:not_available) : input
  end
end