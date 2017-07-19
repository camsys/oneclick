namespace :oneclick do
  desc "Send follow up emails to prompt for feedback"
  task send_feedback_follow_up_emails: :environment do
    Rake::Task["scheduled:send_feedback_follow_up_emails"].invoke
  end
end
