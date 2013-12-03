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
      ServiceTravelerCharacteristicsMap.create(service: service, traveler_characteristic: disabled, group: 1, value: 'true')
      ServiceTravelerCharacteristicsMap.create(service: service, traveler_characteristic: age, group: 2, value: '55', value_relationship_id: 4)

    end # task
  end
end
