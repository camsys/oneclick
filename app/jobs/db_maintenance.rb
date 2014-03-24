class DbMaintenance

  def check_trips_without_user
   all_trips_have_valid_users = Trip.all.distinct(:user_id).pluck(:user_id).all? do |id|
      User.where(id: id).count == 1
    end
    if all_trips_have_valid_users
      puts "DbMaintenance#check_trips_without_user: All trips have valid users."
    else
      puts "*** DbMaintenance#check_trips_without_user: Not all trips have valid users. ***"
      Honeybadger.notify(
        :error_class   => "Data integrity problem",
        :error_message => "Not all trips have valid users"
      )      
    end
  end

end
