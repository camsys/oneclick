# For regularly scheduled tasks
namespace :scheduled do

  desc "Update Booked Trip Status Code through Ecolane"
  task update_booked_trip_statuses: :environment do
    puts "Updating Status of all Booked Ecolane Trips..."
    puts
    bs = BookingServices.new

    updated_results = {}
    UserService.all.each do |us|
      puts "Updating booked trip statuses for User Service #{us.id}..."
      updated_results[us.id] = bs.update_booked_trip_statuses(us)
    end

    puts
    puts "The following user_services and their associated itineraries were updated: ", updated_results.ai
  end

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

# Runs all scheduled tasks
task :scheduled do
  Rake.application.tasks.each do |task|
    if task.name.starts_with?("scheduled:")
      puts "Running #{task.name}"
      task.invoke
    end
  end
end
