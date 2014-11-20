namespace :oneclick do
  desc "Send follow up emails to prompt for feedback"
  task send_feedback_follow_up_emails: :environment do
    Rails.logger.info "#{Time.now}:\tSend Feedback Follow Up Emails"
    if Rating.feedback_on?
      Trip.feedbackable.scheduled_before(Time.now).each do |trip|
        unless trip.user.is_visitor?
          UserMailer.feedback_email(trip).deliver
        end
        trip.update_attributes(needs_feedback_prompt: false)
      end
    end
  end
end
