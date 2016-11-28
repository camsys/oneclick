namespace :oneclick do
  namespace :scheduled do

    # Update Booked Trip Status Code through Ecolane
    task update_booked_trip_statuses: :environment do
      puts "Updating Status of all Booked Ecolane Trips..."
      puts
      bs = BookingServices.new

      UserService.all.each do |us|
        puts "Updating booked trip statuses for User Service #{us.id}..."
        puts
        update_result = bs.update_booked_trip_statuses(us)
        puts
        if update_result
          puts "...updated #{update_result.length} booking statuses."
        else
          puts "...update failed."
        end
      end
    end

  end
end
