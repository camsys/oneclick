namespace :oneclick do
  desc "Send follow up emails to prompt for feedback"
  task send_feedback_follow_up_emails: :environment do
    Rails.logger.info "#{Time.now}:\tSend Feedback Follow Up Emails"
    if Rating.feedback?
      Trip.feedbackable.scheduled_before(Time.now).each do |trip|
        UserMailer.feedback_email(trip).deliver
        trip.update_attributes(needs_feedback_prompt: false)
      end
    end
  end
end
