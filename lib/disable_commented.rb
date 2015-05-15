module DisableCommented

  def deleted_message
    inactive_message ||= "Inactive"
    message = "#{ inactive_message.to_s.capitalize }."
    message += " Reason for Deleting: #{disabled_comment}" if !disabled_comment.blank?
    message
  end

end
