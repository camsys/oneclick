#encoding: utf-8
namespace :oneclick do
  namespace :one_offs do
    desc "Modify characteristics"
    task :modify_characteristics => :environment do
      [{code: 'disabled', desc: 'persons with disabilities'},
        {code: 'no_trans', desc: 'persons with no means of transportation'},
        {code: 'nemt_eligible', desc: 'persons eligible for Medicaid'},
        {code: 'ada_eligible', desc: 'persons eligible for ADA Paratarnsit'},
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
    task :add_fares => :environment do

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
      else
        raise "Don't know how to handle brand #{brand}"
      end
    end

  end
end
