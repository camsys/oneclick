namespace :oneclick do

  desc 'check_trips_without_user (normally a scheduled task)'
  task :check_trips_without_user => :environment do
    DbMaintenance.new.check_trips_without_user
  end

end
