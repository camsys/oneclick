#encoding: utf-8
namespace :oneclick do
  namespace :one_offs do

    desc "Create Booked Trips Report"
    task :create_booked_trips_report => :environment do
      r = Report.where(name: "Booked Trips").first_or_initialize
      r.update(description: "Dashboard of trips booked through OneClick", view_name: "booked_trips_report", class_name: "BookedTripsReport", active: true)
      r.save
    end

    desc "Add Comment to Uber Service"
    task :add_comment_to_uber_service => :environment do
      service_type = ServiceType.unscoped.where(code: "uber_x").first
      if service_type.nil?
        puts 'No uber_x service_type present.'
        next
      end
      ubers = Service.where(service_type: service_type)
      ubers.each do |uber|
        uber.comments.where(locale: "en").first_or_create do |comment|
          comment.comment = "Uber is a ride sharing service similar to a taxi. To request an Uber ride, you'll need to download the Uber App."
          comment.save
        end
      end
    end

    desc "Assign Counties to All Trip Places"
    task :add_counties_to_trip_places => :environment do
      TripPlace.all.each do |trip_place|
        if trip_place.county.blank?
          trip_place.county = trip_place.get_county
          trip_place.save
        end
      end
    end


    desc "Associate Shapefile Boundaries with Services"
    task :add_boundaries => :environment do
      #Delete all polygon-based boundaries
      gcs = GeoCoverage.where(coverage_type: 'polygon')
      gcs.each do |gc|
        gc.service_coverage_maps.destroy_all
        gc.delete
      end

      Boundary.all.each do |b|
        gc = GeoCoverage.new(value: b.agency, coverage_type: 'polygon', polygon: b)
        case b.agency
        when "Cobb Community Transit (CCT)"
          service = Service.find_by_external_id("54104859570670229999")
          ServiceCoverageMap.create(service: service, geo_coverage: gc, rule: 'endpoint_area')
          ServiceCoverageMap.create(service: service, geo_coverage: gc, rule: 'coverage_area')
        when "Cherokee Area Transportation System (CATS)"
          service = Service.find_by_external_id("32138199527497131111")
          ServiceCoverageMap.create(service: service, geo_coverage: gc, rule: 'endpoint_area')
          ServiceCoverageMap.create(service: service, geo_coverage: gc, rule: 'coverage_area')
          #when "Gwinnett County Transit (GCT)"
          #when "Metropolitan Atlanta Rapid Transit Authority"
        end
      end
    end

    task :add_manual_boundaries => :environment do
      z = Zipcode.find_by_zipcode('30309')
      s = Service.find(11)
      s.origin = z.geom
      s.save

      myArray = []
      z.geom.each do |polygon|
        polygon_array = []
        ring_array  = []
        polygon.exterior_ring.points.each do |point|
          ring_array << [point.y, point.x]
        end
        polygon_array < ring_array

        polygon.interior_rings.each do |ring|
          ring_array = []
          ring.each do |point|
            ring_array << [point.y, point.x]
          end
          polygon_array << ring_array
        end
        myArray << polygon_array
      end



    end

    task migrate_comments: :environment do
      [Agency, Provider, Service].each do |commentable_type|
        puts "Migrating #{commentable_type} comments..."
        %w{public private}.each do |visibility|
          puts "...#{visibility}"
          old_field = "#{visibility}_comments_old".to_sym
          method = "#{visibility}_comments".to_sym
          commentable_type.where.not(old_field => nil).each do |c|
            puts ">> #{c.name}"
            c.send(method).create! comment: c.send(old_field), locale: 'en', visibility: visibility
          end
        end
      end
    end

    # Checks if new transit_submode_code translations exist, and creates
    # them if they don't, copying over data from the old mode_code tags.
    # Task is idempotent, may be run multiple times with no additional effect.
    task update_transit_mode_tags: :environment do
      puts "Updating Transit Mode Tags..."

      # List of transit submodes to iterate through
      transit_submodes = Mode.transit.submodes.map {|m| m.name }

      # Iterate through mode codes and create new translation keys as needed
      transit_submodes.each do |m|
        puts "Updating mode codes for #{m}..."

        # Find the old mode translation_key, and a new one if it exists
        old_key = TranslationKey.find_by(name: m)
        new_key = TranslationKey.find_or_create_by!(name: "transit_sub#{m}")

        # As long as an old key exists, identify and copy over old translations
        unless old_key.nil?
          old_translations = Translation.where(translation_key_id: old_key.id)

          # For each existing old translation, check if a new one exists.
          # If not, create one and copy over the old translation's content.
          old_translations.each do |t|
            new_translation = Translation.where(translation_key_id: new_key.id, locale_id: t.locale_id)[0]
            if new_translation.nil?
              puts "No translation exists for #{new_key.name} in #{t.locale.name}. Creating a new translation..."

              # Create a new translation and copy over content from old one.
              new_translation = Translation.new
              new_translation.translation_key_id = new_key.id
	          	new_translation.locale_id = t.locale_id
	          	new_translation.value = t.value
	          	new_translation.is_list = false
	          	new_translation.save!
              puts "New Translation Created: ", new_translation.ai
            else
              puts "New translation already exists for #{new_key.name} in #{t.locale.name}. Skipping..."
            end
          end
        else
          puts "No Translation Key Exists for #{m}."
        end
      end

    end

    # Get rid of UserServices with nil services
    task clean_up_user_services: :environment do
      puts "Cleaning up User Services..."

      UserService.all.each do |us|
        puts "Destroying User Service #{us.id}" if us.service.nil?
        us.destroy if us.service.nil?
      end
    end

    #####################################
    # Transition to New Service Data UI #
    #####################################
    task migrate_to_new_service_data_ui: :environment do
      puts "************************************************"
      puts "Preparing Database for New Service Data Interface."
      puts "This task should be run after running rake db:migrate."
      puts "************************************************"
      puts

      # Make inactive all service characteristics that are not booleans.
      # First, check to see if any of those characteristics are attached to users or services
      puts "Setting #{Characteristic.unscoped.where.not(datatype: "bool").count} non-boolean characteristics to inactive."
      Characteristic.unscoped.where.not(datatype: "bool").each {|c| c.update_attributes(active: false)}
      puts

      # Eliminate UserCharacteristics & ServiceCharacteristics that reference the inactive characteristics
      puts "Eliminating references to nil characteristics..."
      UserCharacteristic.all.each { |uc| puts "Destroying ", uc.destroy.ai if uc.characteristic.nil? }
      ServiceCharacteristic.all.each { |sc| puts "Destroying ", sc.destroy.ai if sc.characteristic.nil? }
      puts

      # Create Fare Structures for Services that don't have them
      puts "Migrating services..."
      Service.all.each do |service|
        puts
        puts "[#{service.id}] #{service.name} (#{service.service_type.code}):"

        # Build fare structures for any services that don't have them.
        if service.fare_structures.empty?
          print "Building fare structures..."
          service.build_fare_structures_by_mode
          puts " #{service.fare_structures.length} new fare structures created."
        end

        # Initialize service with a primary_coverage & secondary if it doesn't have
        service.update_attributes(primary_coverage: CoverageZone.build_coverage_area("")) unless service.primary_coverage
        service.update_attributes(secondary_coverage: CoverageZone.build_coverage_area("")) unless service.secondary_coverage

        ######
        # Build Coverage Zones by parsing Endpoint Array and Coverage Array as recipes and joining to existing coverage recipes.
        unless service.county_endpoint_array.nil?
          print "Parsing county_endpoint_array to Primary Coverage Area..."
          service.update_attributes(primary_coverage: service.primary_coverage.add_to_recipe(service.county_endpoint_array))
          puts " #{service.primary_coverage.recipe} added as primary coverage."
        end

        # Only build secondary coverage zones for paratransit:
        unless service.county_coverage_array.nil? || !ServiceType::PARATRANSIT_MODE_NAMES.include?(service.service_type.code)
          print "Parsing county_coverage_array to Secondary Coverage Area..."
          service.update_attributes(secondary_coverage: service.secondary_coverage.add_to_recipe(service.county_coverage_array))
          puts " #{service.secondary_coverage.recipe} added as secondary coverage."
        end
        ######

        # Check if Service Coverage Maps table still exists before proceeding
        if ActiveRecord::Base.connection.table_exists? 'service_coverage_maps'
          ######
          # Build Coverage Zones by parsing county arrays and copying over old Endpoint and Coverage Areas

          # If service has endpoints, get their geo coverages' names and add as a recipe
          unless service.endpoints.nil? || service.endpoints.empty?
            print "Converting old endpoints to Primary Coverage Area..."
            old_primary = CoverageZone.clean_recipe(service.endpoints.map{ |area| area.geo_coverage && area.geo_coverage.value })
            service.update_attributes(primary_coverage: service.primary_coverage.add_to_recipe(old_primary))
            puts " #{service.primary_coverage.recipe} added as primary coverage."
          end

          # If service has coverages, get their geo coverages' names and add as a recipe
          unless service.coverages.nil? || service.coverages.empty? || !ServiceType::PARATRANSIT_MODE_NAMES.include?(service.service_type.code)
            print "Converting old coverages to Secondary Coverage Area..."
            old_secondary = CoverageZone.clean_recipe(service.coverages.map{ |area| area.geo_coverage && area.geo_coverage.value })
            service.update_attributes(secondary_coverage: service.secondary_coverage.add_to_recipe(old_secondary))
            puts " #{service.secondary_coverage.recipe} added as secondary coverage."
          end
          ######

          ######
          # Build Coverage Zones by directly copying over custom area shape files
          if service.service_coverage_maps

            # If service has a custom endpoint area, replace its primary_coverage with this
            if (service.service_coverage_maps.where(rule: 'endpoint_area').empty? && !service.endpoint_area_geom.nil?)
              print "Converting old custom endpoint geom to Primary Coverage Area..."
              service.update_attributes(primary_coverage: CoverageZone.build_custom_coverage_area(service.endpoint_area_geom.geom))
              puts " custom primary coverage added."
            end

            # If service has a custom coverage area, replace its secondary_coverage with this
            if (service.service_coverage_maps.where(rule: 'coverage_area').empty? && !service.coverage_area_geom.nil?)
              print "Converting old custom coverage geom to Secondary Coverage Area..."
              service.update_attributes(secondary_coverage: CoverageZone.build_custom_coverage_area(service.coverage_area_geom.geom))
              puts " custom secondary coverage added."
            end

          end
          ######
        end

      end

    end

    # Copy Endpoint County Arrays to Ecolane Profile Booking Counties
    task transfer_endpoint_counties_to_ecolane_profiles: :environment do
      puts "Transfering County Endpoint Arrays to Ecolane Booking Profiles..."

      Service.where.not(county_endpoint_array: nil).each do |service|
        if service.ecolane_profile
          if service.ecolane_profile.booking_counties.nil? || service.ecolane_profile.booking_counties.empty?
            puts "Copying #{service.county_endpoint_array} for #{service.name}..."
            service.ecolane_profile.update_attributes(booking_counties: service.county_endpoint_array)
          else
            puts "#{service.name} already has #{service.ecolane_profile.booking_counties} set as its booking counties array."
          end
        else
          puts "#{service.name} has no ecolane profile."
        end
      end

    end

    # Move disallowed_purposes from service to ecolane_profile
    task transfer_disallowed_purposes_to_ecolane_profiles: :environment do
      puts "Transfering Disallowed Purpose Arrays to Ecolane Booking Profiles..."

      Service.where.not(disallowed_purposes: nil).each do |service|
        if service.ecolane_profile
          if service.ecolane_profile.disallowed_purposes.nil?
            puts "Copying #{service.disallowed_purposes_array} for #{service.name}..."
            service.ecolane_profile.update_attributes(disallowed_purposes: service.disallowed_purposes_array)
          else
            puts "#{service.name} already has #{service.ecolane_profile.disallowed_purposes} set as its disallowed purposes array."
          end
        else
          puts "#{service.name} has no ecolane profile."
        end
      end

    end

  end

end
