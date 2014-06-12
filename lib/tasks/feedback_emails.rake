namespace :oneclick do
  desc "Send follow up emails to prompt for feedback"
  task send_feedback_follow_up_emails: :environment do
    Trip.feedbackable.each do |trip|
      UserMailer.feedback_email(trip).deliver
      trip.update_attributes(needs_feedback_prompt: false)
    end
  end
end
