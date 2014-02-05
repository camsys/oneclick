#encoding: utf-8
namespace :oneclick do
  namespace :one_offs do
    desc "Modify characteristics"
    task :modify_characteristics => :environment do
      [{code: 'disabled', desc: 'persons with disabilities'},
        {code: 'no_trans', desc: 'persons with no means of transportation'},
        {code: 'nemt_eligible', desc: 'persons eligible for Medicaid'},
        {code: 'ada_eligible', desc: 'persons eligible for ADA Paratransit'},
        {code: 'veteran', desc: 'military veterans'}].each do |c|
          t = TravelerCharacteristic.find_by_code(c[:code])
          t.update_attributes! desc: c[:desc]
        end
        TravelerCharacteristic.find_by_code('low_income').update_attributes! name: 'low income individuals'

        [{code: 'folding_wheelchair_acceessible', name: 'Folding wheelchair access'},
          {code: 'motorized_wheelchair_accessible', name: 'Motorized wheelchair access'},
          {code: 'lift_equipped', name: 'Wheelchair lift equipped vehicles'},
          {code: 'door_to_door', name: 'Door-to-door assistance'},
          {code: 'curb_to_curb', name: 'Curb-to-curb service'},
          {code: 'driver_assistance_available', name: 'Driver assistance'}].each do |c|
            t = TravelerAccommodation.find_by_code(c[:code])
            t.update_attributes! name: c[:name]
          #
        end

    end # task

    desc "Add Fare Structures for ARC"
    task :add_fares_arc => :environment do

      service = Service.find_by_name('JETS Transportation Program')
      if service and service.fare_structures.count == 0
        FareStructure.create(service: service, fare_type: 2, desc: "Rides are $12 each way inside the perimeter, $13 each way outside the perimeter, and $22 for wheelchair ride each way.  Rides 12 miles or more are charged a mileage surcharge")
      else
        puts "Fare already exists for " + service.name
      end

      service = Service.find_by_name('Medical Transportation by')
      if service and service.fare_structures.count == 0
        FareStructure.create(service: service, fare_type: 0, base: 0.00)
      else
        puts "Fare already exists for " + service.name
      end

      service = Service.find_by_name('Volunteer Transportation from')
      if service and service.fare_structures.count == 0
        FareStructure.create(service: service, fare_type: 0, base: 0.00)
      else
        puts "Fare already exists for " + service.name
      end

      service = Service.find_by_name('Fayette Senior Services')
      if service and service.fare_structures.count == 0
        FareStructure.create(service: service, fare_type: 2, desc: "Sliding scale is used to determine the fee.")
      else
        puts "Fare already exists for " + service.name
      end

      service = Service.find_by_name('Dial-a-Ride for Seniors (DARTS)')
      if service and service.fare_structures.count == 0
        FareStructure.create(service: service, fare_type: 0, base: 0.00)
      else
        puts "Fare already exists for " + service.name
      end

      service = Service.find_by_name('Cobb Senior Services')
      if service and service.fare_structures.count == 0
        FareStructure.create(service: service, fare_type: 0, base: 1.00)
      else
        puts "Fare already exists for " + service.name
      end

      service = Service.find_by_name('CCT Paratransit')
      if service and service.fare_structures.count == 0
        FareStructure.create(service: service, fare_type: 0, base: 4.00)
      else
        puts "Fare already exists for " + service.name
      end

      service = Service.find_by_name('Cherokee Area')
      if service and service.fare_structures.count == 0
        FareStructure.create(service: service, fare_type: 2, desc: "Call for current rates.  One way $1.50 for up to 5 miles and $0.30 each additional mile.  Wheelchair is $3.85 for up to 10 miles and $0.42 each additional mile.")
      else
        puts "Fare already exists for " + service.name
      end

      service = Service.find_by_name('I Care')
      if service and service.fare_structures.count == 0
        FareStructure.create(service: service, fare_type: 0, base: 0.00)
      else
        puts "Fare already exists for " + service.name
      end


      #Traveler Characteristics Requirements
      disabled = TravelerCharacteristic.find_by_code('disabled')
      age = TravelerCharacteristic.find_by_code('age')
      c = GeoCoverage.new(value: 'Dekalb', coverage_type: 'county_name')
      ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'residence')

      ServiceTravelerCharacteristicsMap.create(service: service, traveler_characteristic: disabled, group: 1, value: 'true')
      ServiceTravelerCharacteristicsMap.create(service: service, traveler_characteristic: age, group: 2, value: '55', value_relationship_id: 4)

    end # task

    desc "Add ESP Identifiers to Providers and Services"
    task :add_esp_ids => :environment do

      service = Service.find_by_name('JETS Transportation Program')
      if service
        p "updated service: " + service.name
        service.external_id = "89144135357234431111"
        service.save
      end

      service = Service.find_by_name('Medical Transportation by')
      if service
        p "updated service: " + service.name
        service.external_id = "32138199527497131111"
        service.save
      end

      service = Service.find_by_name('Fayette Senior Services')
      if service
        p "updated service: " + service.name
        service.external_id = "86869601213076809999"
        service.save
      end

      service = Service.find_by_name('Dial-a-Ride for Seniors (DARTS)')
      if service
        p "updated service: " + service.name
        service.external_id = "54104859570670229999"
        service.save
      end

      service = Service.find_by_name('CCT Paratransit')
      if service
        p "updated service: " + service.name
        service.external_id = "57874876269921009999"
        service.save
      end

      service = Service.find_by_name('Cherokee Area')
      if service
        p "updated service: " + service.name
        service.external_id = "65980602734372809999"
        service.save
      end

      provider = Provider.find_by_external_id("esp#6")
      if provider
        p "updating provider:  "  + provider.name
        provider.external_id = "17471"
        provider.save
      end

      provider = Provider.find_by_external_id("esp#7")
      if provider
        p "updating provider:  "  + provider.name
        provider.external_id = "17472"
        provider.save
      end

      provider = Provider.find_by_external_id("esp#3")
      if provider
        p "updating provider:  "  + provider.name
        provider.external_id = "17436"
        provider.save
      end

      provider = Provider.find_by_external_id("esp#15")
      if provider
        p "updating provider:  "  + provider.name
        provider.external_id = "17625"
        provider.save
      end

      provider = Provider.find_by_external_id("esp#22")
      if provider
        p "updating provider:  "  + provider.name
        provider.external_id = "18575"
        provider.save
      end

    end # task

    desc "Add Fare Structures for Broward"
    task :add_fares_broward => :environment do

      service = Service.find_by_name('BC Paratransit')
      if service and service.fare_structures.count == 0
        FareStructure.create(service: service, fare_type: 0, base: 3.50)
      else
        puts "Fare already exists for " + service.name
      end

      service = Service.find_by_name('Social Services: Limited Transportation')
      if service and service.fare_structures.count == 0
        FareStructure.create(service: service, fare_type: 2, desc: "Tamarac Para-transit fee is $30.00 for 3 months or 40.00 for 6 months per person for unlimited marketing and medical transportation.")
      else
        puts "Fare already exists for " + service.name
      end

      service = Service.find_by_name('Social Services')
      if service and service.fare_structures.count == 0
        FareStructure.create(service: service, fare_type: 0, base: 1)
      else
        puts "Fare already exists for " + service.name
      end

      service = Service.find_by_name('Joseph Meyerhoff Senior Center')
      if service and service.fare_structures.count == 0
        FareStructure.create(service: service, fare_type: 0, base: 0, desc: "Free service for Senior Center members.")
      else
        puts "Fare already exists for " + service.name
      end

      service = Service.find_by_name('Road to Recovery')
      if service and service.fare_structures.count == 0
        FareStructure.create(service: service, fare_type: 0, base: 0)
      else
        puts "Fare already exists for " + service.name
      end

      service = Service.find_by_name('Special & Community Support Services')
      if service and service.fare_structures.count == 0
        FareStructure.create(service: service, fare_type: 0, base: 3)
      else
        puts "Fare already exists for " + service.name
      end


    end # task

    desc "Add Fare Structures for Broward"
    task :add_fares_broward => :environment do

      service = Service.find_by_name('BC Paratransit')
      if service and service.fare_structures.count == 0
        FareStructure.create(service: service, fare_type: 0, base: 3.50)
      else
        puts "Fare already exists for " + service.name
      end

      service = Service.find_by_name('Social Services: Limited Transportation')
      if service and service.fare_structures.count == 0
        FareStructure.create(service: service, fare_type: 2, desc: "Tamarac Para-transit fee is $30.00 for 3 months or 40.00 for 6 months per person for unlimited marketing and medical transportation.")
      else
        puts "Fare already exists for " + service.name
      end

      service = Service.find_by_name('Social Services')
      if service and service.fare_structures.count == 0
        FareStructure.create(service: service, fare_type: 0, base: 1)
      else
        puts "Fare already exists for " + service.name
      end

      service = Service.find_by_name('Joseph Meyerhoff Senior Center')
      if service and service.fare_structures.count == 0
        FareStructure.create(service: service, fare_type: 0, base: 0, desc: "Free service for Senior Center members.")
      else
        puts "Fare already exists for " + service.name
      end

      service = Service.find_by_name('Road to Recovery')
      if service and service.fare_structures.count == 0
        FareStructure.create(service: service, fare_type: 0, base: 0)
      else
        puts "Fare already exists for " + service.name
      end

      service = Service.find_by_name('Special & Community Support Services')
      if service and service.fare_structures.count == 0
        FareStructure.create(service: service, fare_type: 0, base: 3)
      else
        puts "Fare already exists for " + service.name
      end


    end # task

    desc "Add Companion Allowed Accommodation"
    task :add_companion => :environment do
      companion_allowed = TravelerAccommodation.find_or_initialize_by_code('companion_allowed')
      companion_allowed.name = 'Traveler Companion Permitted'
      companion_allowed.note = 'Do you travel with a companion?'
      companion_allowed.datatype = 'bool'
      companion_allowed.save()
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
        gc = GeoCoverage.new(value: b.agency, coverage_type: 'polygon', boundary: b)
        case b.agency
          when "Cobb Community Transit (CCT)"
            service = Service.find_by_external_id("54104859570670229999")
            ServiceCoverageMap.create(service: service, geo_coverage: gc, rule: 'origin')
            ServiceCoverageMap.create(service: service, geo_coverage: gc, rule: 'destination')
          when "Cherokee Area Transportation System (CATS)"
            service = Service.find_by_external_id("32138199527497131111")
            ServiceCoverageMap.create(service: service, geo_coverage: gc, rule: 'origin')
            ServiceCoverageMap.create(service: service, geo_coverage: gc, rule: 'destination')
          #when "Gwinnett County Transit (GCT)"
          #when "Metropolitan Atlanta Rapid Transit Authority"
        end
      end
    end

    desc "Add Disabled American Vets Van to Lebanon"
    task :add_dav => :environment do

      if TripPurpose.find_by_name('Visit Lebanon VA Medical Center').nil?

        lebanon = TripPurpose.create(
            name: 'Visit Lebanon VA Medical Center',
            note: 'Visit Lebanon VA Medical Center',
            active: 1,
            sort_order: 2)

        provider = {name: 'Veterans Affairs', contact: '', external_id:  "6"}
        p = Provider.create! provider
        p.save

        #Create service Disabled American Vets van
        paratransit = ServiceType.find_by_name('Paratransit')
        service = Service.create(name: 'Disabled American Veterans: Van to Lebanon VA', provider: p, service_type: paratransit, advanced_notice_minutes: 5*24*60)
        #Add Schedules
        (1..5).each do |n|
          Schedule.create(service: service, start_time:"13:00", end_time: "17:00", day_of_week: n)
        end

        FareStructure.create(service: service, fare_type: 0, base: 0.00, desc: 'The Transportation Van is a VOLUNTEERED shuttle that runs from York Out Patient Clinic to Lebanon Hospital. The van is a 7-8 passenger van and operates Monday thru Friday 8:00 AM-12:00 PM. The van leaves normally one hour and a half to an hour and fifteen minutes prior to the first appointment (i.e. appt in Lebanon is at 8:00A.M. departure time is 6:45 AM) and leaves Lebanon VA to come back to York at 12:00 PM. Any appointments after 11:30 AM, is the Patients responsibility to obtain return transportation to York. The DRIVER is NOT responsible for patients return trip to York if appointment runs past 12:00 P.M.<br>
When scheduling appointment(s), patients must inform the scheduling clerk that they are passengers on the York Shuttle Van and request appointment(s) between 8:00 A.M. and 11:00 A.M. to accommodate the vans normal operation schedule. Once the appointment in Lebanon is scheduled the veteran needs to call 771-9218 five (5) working days prior to the appointment to make arrangements to get onto the van. We take the first 8 Veterans and can take stand by names but cannot guarantee a ride. The van driver will get the list of veteran’s names 2-3 days prior to the date and will call the veterans with a departure time. The veterans are responsible for providing their own transportation to York Clinic for departure to Lebanon.')

        #Trip purpose requirements
        ServiceTripPurposeMap.create(service: service, trip_purpose: lebanon, value: 'true')

        #Add geographic restrictions
        ['York', 'Adams'].each do |z|
          c = GeoCoverage.new(value: z, coverage_type: 'county_name')
          ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'origin')
        end

        #Traveler Accommodations Requirements
        folding_wheelchair_accessible = TravelerAccommodation.find_by_code('folding_wheelchair_acceessible')
        [folding_wheelchair_accessible].each do |n|
          ServiceTravelerAccommodationsMap.create(service: service, traveler_accommodation: n, value: 'true')
        end

      else
        puts 'Already added Disabled American Vets van'
      end

    end

    desc "Add Rabbit General Public"
    task :add_rabbit_general => :environment do
      provider = Provider.find_by_external_id('1')

      #Create service Disabled American Vets van
      paratransit = ServiceType.find_by_name('Paratransit')
      service = Service.create(name: 'General Public Shared Ride', provider: provider, service_type: paratransit, advanced_notice_minutes: 24*60)

      #Add Schedules
      (1..5).each do |n|
        Schedule.create(service: service, start_time:"5:45", end_time: "23:30", day_of_week: n)
      end
      Schedule.create(service: service, start_time:"7:15", end_time: "21:45", day_of_week: 6)
      Schedule.create(service: service, start_time:"9:15", end_time: "18:00", day_of_week: 0)

      service.schedules.each do |sc|
        sc.start_time += 5*3600
        sc.end_time += 5*3600
        sc.save
      end

      #Add geographic restrictions
      ['York', 'Adams'].each do |z|
        c = GeoCoverage.new(value: z, coverage_type: 'county_name')
        ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'origin')
      end
      ['York', 'Adams'].each do |z|
        c = GeoCoverage.new(value: z, coverage_type: 'county_name')
        ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'destination')
      end

      medical = TripPurpose.find_by_name('Medical')
      cancer = TripPurpose.find_by_name('Cancer Treatment')
      #Trip purpose requirements
      [medical, cancer].each do |n|
        ServiceTripPurposeMap.create(service: service, trip_purpose: n, value: 'true')
      end
      FareStructure.create(service: service, fare_type: 2, desc:  "Zone 1: $15.65, Zone 2: $22.00, Zone 3: $30.50, Zone 4: $44.25")

      #Traveler Accommodations Requirements
      folding_wheelchair_accessible = TravelerAccommodation.find_by_code('folding_wheelchair_acceessible')
      motorized_wheelchair_accessible = TravelerAccommodation.find_by_code('motorized_wheelchair_accessible')
      curb_to_curb = TravelerAccommodation.find_by_code('curb_to_curb')
      [motorized_wheelchair_accessible, folding_wheelchair_accessible, curb_to_curb].each do |n|
        ServiceTravelerAccommodationsMap.create(service: service, traveler_accommodation: n, value: 'true')
      end

    end

    desc "Add URSL to PA"
    task :add_urls_to_pa => :environment do

      service = Service.find_by_name('Senior Shared Ride')
      service.url = "http://www.rabbittransit.org/"
      service.save

      service = Service.find_by_name('Shared Ride for Ages 60-64')
      service.url = "http://www.rabbittransit.org/"
      service.save

      service = Service.find_by_name('Medical Assistance Transportation Program')
      service.url = "http://www.rabbittransit.org/"
      service.save

      service = Service.find_by_name('ADA Complementary Service')
      service.url = "http://www.rabbittransit.org/"
      service.save

      service = Service.find_by_name('Service for Persons with Disabilities')
      service.url = "http://www.rabbittransit.org/"
      service.save

      service = Service.find_by_name('Staying Connected')
      service.url = "http://www.stayingconnectedyork.org/"
      service.save

      service = Service.find_by_name('Road to Recovery Program')
      service.url = "http://www.cancer.org/treatment/supportprogramsservices/road-to-recovery"
      service.save

      service = Service.find_by_name('Touch a Life')
      service.url = "http://www.lutheranscp.org/cos/touch-a-life"
      service.save

      service = Service.find_by_name('Area Agency on Aging')
      service.url = "http://yorkcountypa.gov/health-human-services/agency-on-aging.html"
      service.save

      service = Service.find_by_name('General Public Shared Ride')
      service.url = "http://www.rabbittransit.org/"
      service.save
    end

    desc "Add 5 hours"
    task :add_five_hours => :environment do
      Schedule.all.each do |s|
        s.start_time += (5*3600)
        s.end_time += (5*3600)
        s.save
      end
    end


    desc "Set up cms entries"
    task cms: :environment do
      Cms::Site.destroy_all
      site = Cms::Site.where(identifier: 'default').first_or_create(label: 'default', hostname: 'localhost', path: 'content')
      # site.snippets.create! identifier: 'plan-a-trip', label: 'plan a trip', content: '<div class="well">This is the content for Plan A Trip</div>'
      # site.snippets.create! identifier: 'home-top-logged-in', label: 'home-top-logged-in', content: '<div class="well">This is content for home-top-logged-in</div>'
      # site.snippets.create! identifier: 'home-top', label: 'home-top', content: '<div class="well">This is content for home-top</div>'
      # site.snippets.create! identifier: 'home-bottom-left-logged-in', label: 'home-bottom-left-logged-in', content: '<div class="well">This is content for home-bottom-left-logged-in</div>'
      # site.snippets.create! identifier: 'home-bottom-center-logged-in', label: 'home-bottom-center-logged-in', content: '<div class="well">This is content for home-bottom-center-logged-in</div>'
      # site.snippets.create! identifier: 'home-bottom-right-logged-in', label: 'home-bottom-right-logged-in', content: '<div class="well">This is content for home-bottom-right-logged-in</div>'
      # site.snippets.create! identifier: 'home-bottom-left', label: 'home-bottom-left', content: '<div class="well">This is content for home-bottom-left</div>'
      # site.snippets.create! identifier: 'home-bottom-center', label: 'home-bottom-center', content: '<div class="well">This is content for home-bottom-center</div>'
      # site.snippets.create! identifier: 'home-bottom-right', label: 'home-bottom-right', content: '<div class="well">This is content for home-bottom-right</div>'
      brand = Oneclick::Application.config.brand
      case brand

      when 'arc'
        text = <<EOT
<h2 style="text-align: justify;">1-Click/ARC helps you find options to get from here to there, using public transit,
 door-to-door services, and specialized transportation.  Give it a try, and
 <a href="mailto://OneClick@camsys.com">tell us</a> what you think.</h2>
EOT
        site.snippets.create! identifier: 'home-top-logged-in', label: 'home-top-logged-in', content: text
        site.snippets.create! identifier: 'home-top', label: 'home-top', content: text
        text = <<EOT
1-Click/ARC was funded by the
 <a href="http://www.fta.dot.gov/grants/13094_13528.html" target=_blank>Veterans Transportation 
 Community Living Initiative</a>.
EOT
        site.snippets.create! identifier: 'home-bottom-left-logged-in', label: 'home-bottom-left-logged-in', content: text
        site.snippets.create! identifier: 'home-bottom-left', label: 'home-bottom-left', content: text
        text = <<EOT
<span style="float: right;">1-Click/ARC is sponsored by the 
<a href="http://www.atlantaregional.com/" target=_blank>Atlanta Regional Commission</a>.</span>
EOT
        site.snippets.create! identifier: 'home-bottom-right-logged-in', label: 'home-bottom-right-logged-in', content: text
        site.snippets.create! identifier: 'home-bottom-right', label: 'home-bottom-right', content: text
        text = <<EOT
Tell us about your trip.  The more information you give us, the more options we can find!
EOT
        site.snippets.create! identifier: 'plan-a-trip', label: 'plan a trip', content: text

      when 'pa'
        text = <<EOT
<h2 style="text-align: justify;">1-Click/PA helps you find options to get from here to there, using public transit,
 door-to-door services, and specialized transportation.  Give it a try, and
 <a href="mailto://OneClick@camsys.com">tell us</a> what you think.</h2>
EOT
        site.snippets.create! identifier: 'home-top-logged-in', label: 'home-top-logged-in', content: text
        site.snippets.create! identifier: 'home-top', label: 'home-top', content: text
        text = <<EOT
1-Click/PA was funded by the
 <a href="http://www.fta.dot.gov/grants/13094_13528.html" target=_blank>Veterans Transportation 
 Community Living Initiative</a>.
EOT
        site.snippets.create! identifier: 'home-bottom-left-logged-in', label: 'home-bottom-left-logged-in', content: text
        site.snippets.create! identifier: 'home-bottom-left', label: 'home-bottom-left', content: text
        text = <<EOT
<span style="float: right;">1-Click/PA is sponsored by the
<a href="http://www.dot.state.pa.us/" target=_blank>Pennsylvania Department of Transportation</a> and the
<a href="http://www.rabbittransit.org/" target=_blank>York Adams Transportation Authority</a>.</span>
EOT
        site.snippets.create! identifier: 'home-bottom-right-logged-in', label: 'home-bottom-right-logged-in', content: text
        site.snippets.create! identifier: 'home-bottom-right', label: 'home-bottom-right', content: text
        text = <<EOT
Tell us about your trip.  The more information you give us, the more options we can find!
EOT
        site.snippets.create! identifier: 'plan-a-trip', label: 'plan a trip', content: text

      when 'broward'
        text = <<EOT
<h2 style="text-align: justify;">1-Click/Broward helps you find options to get from here to there, using public transit,
 door-to-door services, and specialized transportation.  Give it a try, and
 <a href="mailto://OneClick@camsys.com">tell us</a> what you think.</h2>
EOT
        site.snippets.create! identifier: 'home-top-logged-in', label: 'home-top-logged-in', content: text
        site.snippets.create! identifier: 'home-top', label: 'home-top', content: text
        text = <<EOT
1-Click/Broward was funded by the
 <a href="http://www.fta.dot.gov/grants/13094_13528.html" target=_blank>Veterans Transportation 
 Community Living Initiative</a>.
EOT
        site.snippets.create! identifier: 'home-bottom-left-logged-in', label: 'home-bottom-left-logged-in', content: text
        site.snippets.create! identifier: 'home-bottom-left', label: 'home-bottom-left', content: text
        text = <<EOT
<span style="float: right;">1-Click/Broward is sponsored by 
<a href="http://211-broward.org/" target=_blank>2-1-1 Broward</a>.</span>
EOT
        site.snippets.create! identifier: 'home-bottom-right-logged-in', label: 'home-bottom-right-logged-in', content: text
        site.snippets.create! identifier: 'home-bottom-right', label: 'home-bottom-right', content: text
        text = <<EOT
Tell us about your trip.  The more information you give us, the more options we can find!
EOT
        site.snippets.create! identifier: 'plan-a-trip', label: 'plan a trip', content: text
      else
        raise "Don't know how to handle brand #{brand}"
      end
    end

  end
end
