namespace :update do


  desc "Help"
  task help: :environment do
     puts "During each release run rake update:<release>"
     puts "IMPORTANT!  All tasks here should be idempotent."
  end

  desc "v1.8.2"
  task "v1.8.2" => :environment do
    Rake::Task["db:migrate"].invoke

    # Transfering Data from old to new geoms occurs in drop_geo_coverages migration
    # Rake::Task["oneclick:one_offs:migrate_to_new_service_data_ui"].invoke

    Rake::Task["oneclick:load_locales"].invoke
    Rake::Task["oneclick:one_offs:clean_up_user_services"].invoke #Not necessary for the new Service-Data UI, but running the following may fix broken User Profiles:

    ### Create Booked Trips Report
    #Report.create(name: "Booked Trips", description: "Dashboard of trips booked through OneClick", view_name: "booked_trips_report", class_name: "BookedTripsReport", active: true)
    Rake::Task["oneclick:one_offs:create_booked_trips_report"].invoke
    Rake::Task["scheduled:update_booked_trip_statuses"].invoke

    puts 'Additional Release Notes:'
    puts 'FOR PA, set config.restrict_services_to_origin_county = true'
    puts "For PA, in Heroku set rake scheduled:update_booked_trip_statuses as a scheduled task."
    puts "For GTC, set config.show_paratransit_fleet_size_and_trip_volume = true"
    puts "For every instance be sure to set the state config: OneclickConfiguration.where(code: 'state').first_or_initialize.update_attributes(value: 'MA')"
    puts "For every instance, in Heroku change scheduled task from oneclick:send_feedback_follow_up_emails to scheduled:send_feedback_follow_up_emails"

  end

end

task :update do
  Rake::Task["update:default"].invoke
end
