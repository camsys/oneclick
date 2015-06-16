module DisableCommented

  def deleted_message
    message = "#{ TranslationEngine.translate_text(:inactive).to_s.capitalize }."
    message += " #{ TranslationEngine.translate_text(:reason_for_deleting) } #{disabled_comment}" if !disabled_comment.blank?
    message
  end

end
