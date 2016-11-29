namespace :update do


  desc "Help"
  task help: :environment do
     puts "During each release run rake update:<release>"
     puts "No guarantee that these tasks are idempotent."
  end

  desc "v1.8.2"
  task "v1.8.2" => :environment do
    Rake::Task["db:migrate"].invoke
    Rake::Task["oneclick:load_locales"].invoke
    Rake::Task["oneclick:one_offs:migrate_to_new_service_data_ui"].invoke #This version implements the streamlined Provider and Service Data Admin UI. In order to do this without breaking things, run the following (after db:migrate):
    Rake::Task["oneclick:one_offs:clean_up_user_services"].invoke #Not necessary for the new Service-Data UI, but running the following may fix broken User Profiles:

    ### Create Booked Trips Report
    Report.create(name: "Booked Trips", description: "Dashboard of trips booked through OneClick", view_name: "booked_trips_report", class_name: "BookedTripsReport", active: true)
    Rake::Task["oneclick:scheduled:update_booked_trip_statuses"]

    puts 'Additional Release Notes:'
    puts 'FOR PA, set config.restrict_services_to_origin_county = true'
    puts "For every instance be sure to set the state config: OneclickConfiguration.where(code: 'state').first_or_initialize.update_attributes(value: 'MA')"
  end

end

task :update do
  Rake::Task["update:default"].invoke
end