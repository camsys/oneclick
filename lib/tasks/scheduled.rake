# For regularly scheduled tasks
namespace :scheduled do
  
  # Update Booked Trip Status Code through Ecolane
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
