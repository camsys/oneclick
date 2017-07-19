namespace :ecolane do

  desc "Update Ecolane POIs"
  task :update_pois => :environment do

    booking_services = BookingServices.new
    messages = []
    global_error = false

    #Ecolane POIs are broken down by system.  First, get a list of all the unique Ecolane Systems
    systems = []
    services  = []
    EcolaneProfile.all.each do |ecolane_profile|
      if ecolane_profile.service.active? and not ecolane_profile.system.blank? and not ecolane_profile.system.in? systems and not ecolane_profile.token.blank?
        systems << ecolane_profile.system
        services << ecolane_profile.service
      end
    end

    services.each do |service|
      local_error = false
      system = service.ecolane_profile.system

      #For each system, get or create a poi_type for the system.  Having a separate poi_type for each system allows us to update/delete POIs on a system by system basis
      poi_type = PoiType.where(name: "ecolane_" + system.to_s).first_or_create do |new_poi_type|
        new_poi_type.active = true
      end

      # Get the current POIs and mark them as old
      old_pois = Poi.where(poi_type: poi_type)
      old_pois.update_all(old: true)

      begin
        # Get a Hash of new POIs from Ecolane
        new_poi_hashes = booking_services.get_pois_for_service service

        if new_poi_hashes.nil?
          #If anything goes wrong, delete the new pois and reinstate the old_pois
          Poi.where(poi_type: poi_type, old: false).delete_all
          old_pois.update_all(old: false)
          messages << "Error loading POIs for System: #{system}, service_id: #{service.id}. Unable to retrieve POIs"
          global_error = true
          local_error = true
          next
        end

        new_poi_hashes.each do |hash|


          if Poi.is_new.where('lower(address1) = ? AND lower(city) = ?', hash[:address1].downcase, hash[:city].downcase).count > 0
            puts 'DUPLICATE '
            puts hash.ai
            next
          end

          new_poi = Poi.new hash
          new_poi.poi_type = poi_type
          new_poi.state = new_poi.state_code
          new_poi.old = false
          #All POIs need a name, if Ecolane doesn't define one, then name it after the Address
          if new_poi.name.blank? or new_poi.name.downcase == 'home'
            new_poi.name = new_poi.address1
          end
          new_poi.save
        end

      rescue Exception => e
        #If anything goes wrong, delete the new pois and reinstate the old_pois
        Poi.where(poi_type: poi_type, old: false).delete_all
        old_pois.update_all(old: false)
        messages << "Error loading POIs for #{system}. #{e.message}."
        global_error = true
        local_error = true
      end

      unless local_error
        #If we made it this far, then we have a new set of POIs and we can delete the old ones.
        Poi.where(poi_type: poi_type, old: true).delete_all
        new_poi_count = Poi.where(poi_type: poi_type).count
        messages << "Successfully loaded  #{new_poi_count} POIs for #{system}."
      end

    end

    #Email the result
    messages.each do |message|
      puts message
    end

    subject = (global_error ? "Error loading Ecolane POIs" : "Successfully Loaded Ecolane POIs")
    UserMailer.poi_upload_results(Oneclick::Application.config.support_emails.split(','), subject, messages).deliver!

  end #update_pois

end #ecolane