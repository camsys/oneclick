namespace :update do


  desc "Help"
  task help: :environment do
     puts "During each release run rake update:<release>"
     puts "IMPORTANT!  All tasks here should be idempotent."
  end

  desc "v1.8.2"
  task "v1.8.2", [:state] => :environment do |t, args|
    # Check if a state is passed as a parameter`
    if args[:state].is_a?(String) &&
        args[:state].length == 2 &&
        OneclickConfiguration.where(code: 'state').first_or_initialize.update_attributes(value: args[:state].upcase)
      puts "Set State to #{OneclickConfiguration.find_by(code: 'state').value}..."
    else # Break out of the rake task if not.
      puts "Please provide a 2-letter state abbreviation as a parameter, and enclose rake task in quotations."
      puts 'e.g. rake "update:v1.8.2[PA]".'
      puts 'Aborting...'
      next
    end

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
    puts "Run rake oneclick:one_offs:migrate_to_new_service_data_ui if needed to re-copy data from services."
  end

  desc "v1.8.3"
  task "v1.8.3" => :environment do
    # This task is run as part of the migration that destroys county_endpoint_array:
    # Rake::Task["onelick:one_offs:transfer_endpoint_counties_to_ecolane_profiles"].invoke # Copies over county_endpoint_array data

    # Migrate and Load Locales
    Rake::Task["db:migrate"].invoke
    Rake::Task["oneclick:load_locales"].invoke

    Rake::Task["oneclick:one_offs:add_comment_to_uber_service"].invoke #Make sure that Uber Services have a public comment.
    Rake::Task["cleanup:destroy_orphaned_records"].invoke # Destroys orphaned records that could cause issues with updated code.
    Rake::Task["oneclick:one_offs:create_planned_trips_report"].invoke # Create the Planned Trips Report for all instances

    puts 'Additional Release Notes:'
    puts "If this instance uses a booking service, run 'rake oneclick:one_offs:create_booked_trips_report' to setup the Booked Trips Report."
    puts "For CPTA, destroy the Provider named 'Shared Ride', and then run 'rake oneclick:create_ecolane_services' and 'rake oneclick:setup_ecolane_services'"
  end

  desc "v1.8.4"
  task "v1.8.4" => :environment do
    puts 'Additional Release Notes:'
    puts "Look through services and check to see if any have schedules ending at 12:00am. If so, make sure the last 12:00am in the list is selected, rather than the first one."

    #Delete duplicate modes.  Don't delete all the duplicate modes because it might cause issues.  But if there is a mode that is inactive and a duplicate of that mode that is active, then delete the inactive mode
    Rake::Task["oneclick:one_offs:update_cancel_trip_translation"].invoke
    Rake::Task["oneclick:one_offs:delete_duplicate_modes"].invoke
    Rake::Task['oneclick:load_locales'].invoke

  end

  desc "v1.9.0"
  task "v1.9.0" => :environment do
    Rake::Task["db:migrate"].invoke
  end

  desc "v1.10.0"
  task "v1.10.0" => :environment do
    Rake::Task["oneclick:set_washington"].invoke #Adds washington county to active Ecolane Services
  end

  desc "v1.11.0"
  task "v1.11.0" => :environment do
  end

  desc "v1.12.0"
  task "v1.12.0" => :environment do
    Rake::Task["db:migrate"].invoke
  end

  desc "v1.14.0"
  task "v1.14.0" => :environment do
    Rake::Task["db:migrate"].invoke
  end

end
task :update do
  Rake::Task["update:default"].invoke
  Rake::Task["oneclick:load_locales"].invoke
end
