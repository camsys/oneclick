#encoding: utf-8
namespace :oneclick do
  namespace :one_offs do

    desc "Create Booked Trips Report"
    task :create_booked_trips_report => :environment do
      r = Report.where(name: "Booked Trips").first_or_initialize
      r.update(description: "Dashboard of trips booked through OneClick", view_name: "booked_trips_report", class_name: "BookedTripsReport", active: true)
      r.save
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

    # Transition to New Service Data UI
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

        # Build Coverage Zones by parsing Endpoint Array and Coverage Array as recipes and joining to existing coverage recipes.
        unless service.county_endpoint_array.nil?
          recipe = service.county_endpoint_array.join(', ') + (service.primary_coverage.nil? ? "" : ", #{service.primary_coverage.recipe}")
          print "Parsing Primary Coverage Area..."
          service.update_attributes(primary_coverage: CoverageZone.build_coverage_area(recipe))
          puts " #{service.primary_coverage.recipe} added as primary coverage."
        end

        # Only build secondary coverage zones for paratransit
        unless service.county_coverage_array.nil? || service.service_type.code != "paratransit"
          recipe = service.county_coverage_array.join(', ') + (service.secondary_coverage.nil? ? "" : ", #{service.secondary_coverage.recipe}")
          puts "Parsing Secondary Coverage Area..."
          service.update_attributes(secondary_coverage: CoverageZone.build_coverage_area(recipe))
          puts " #{service.secondary_coverage.recipe} added as secondary coverage."
        end

      end

    end

  end

end
