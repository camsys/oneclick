# For regularly scheduled tasks
namespace :scheduled do

  desc "Update Booked Trip Status Code through Ecolane"
  task update_booked_trip_statuses: :environment do
    puts "Updating Status of all Booked Ecolane Trips..."
    puts

    puts "First, cleaning up test user trips..."
    puts
    ecolane_test_users = [
      '79109',      '7832',       '2581',
      '79110',      '18226',      'test4',
      '1000004436', 'test1',      '0001',
      '1000004064', 'test2',      '1000004063'
    ].map {|id| UserService.where(external_user_id: id)}.flatten.map {|us| us.user_profile.user}

    ecolane_test_users.each do |user|
      puts "Cleaning up trips for #{user.email}..."
      trips = user.trips
      trip_parts = TripPart.where(trip_id: trips.pluck(:id))
      itineraries = Itinerary.where(trip_part_id: trip_parts.pluck(:id))
      puts "...#{Trip.destroy(trips.pluck(:id)).count} trips destroyed"
      puts "...#{TripPart.destroy(trip_parts.pluck(:id)).count} trip_parts destroyed"
      puts "...#{Itinerary.destroy(itineraries.pluck(:id)).count} itineraries destroyed"
    end


    bs = BookingServices.new

    updated_results = {}
    UserService.all.each do |us|
      puts "Updating booked trip statuses for User Service #{us.id}..."
      updated_results[us.id] = bs.update_booked_trip_statuses(us)
    end

    # Capture any "canceled" statuses that weren't categorized:
    puts
    puts "Categorizing canceled Ecolane Bookings..."
    canceled_ecolane_bookings = EcolaneBooking.joins(:itinerary).where(booking_status_code: "canceled")
    internal_canceled_ebs = canceled_ecolane_bookings.where(:itineraries => {booking_confirmation: nil}).references(:itineraries)
    external_canceled_ebs = canceled_ecolane_bookings.where.not(:itineraries => {booking_confirmation: nil}).references(:itineraries)
    internal_count = internal_canceled_ebs.update_all(booking_status_code: "canceled via FindMyRide")
    external_count = external_canceled_ebs.update_all(booking_status_code: "canceled via agent")
    puts "#{internal_count} statuses updated to 'canceled via FindMyRide'"
    puts "#{external_count} statuses updated to 'canceled via agent'"

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
