#encoding: utf-8
namespace :oneclick do
  namespace :pa_fares do
    desc "Modify fares for PA"
    task :add_fares => :environment do

      service = Service.find_by_name('Senior Shared Ride')
      if service and service.fare_structures.count == 0
        FareStructure.create(service: service, fare_type: 2, desc: "For Senior Center, Medical, Pharmacy, Dialysis or Adult Day Care:<br>Zone 1: $1.50, Zone 2: $3.00, Zone 3: $3.50, Zone 4: $4.50.<br><br> Other Trips:<br>Zone 1: $2.35, Zone 2: $3.30, Zone 3: $4.60, Zone 4: $6.65")
      else
        puts "Fare already exists for " + service.name
      end

      service = Service.find_by_name('Shared Ride for Ages 60-64')
      if service and service.fare_structures.count == 0
        FareStructure.create(service: service, fare_type: 2, desc: "For MA Eligible and going to Senior Center or Adult Day Care:<br>Zone 1: $1.50, Zone 2: $6.50, Zone 3: $7.00, Zone 4: $8.25.<br><br>   Other Trips: <br>Zone 1: $15.65, Zone 2: $22.00, Zone 3: $30.50, Zone 4: $44.25")
      else
        puts "Fare already exists for " + service.name
      end

      service = Service.find_by_name('Medical Assistance Transportation Program')
      if service and service.fare_structures.count == 0
        FareStructure.create(service: service, fare_type: 0, base: 0.00)
      else
        puts "Fare already exists for " + service.name
      end

      service = Service.find_by_name('ADA Complementary Service')
      if service and service.fare_structures.count == 0
        FareStructure.create(service: service, fare_type: 2, desc: "Zone 1: $3.10, Zone 2: $4.00")
      else
        puts "Fare already exists for " + service.name
      end

      service = Service.find_by_name('Service for Persons with Disabilities')
      if service and service.fare_structures.count == 0
        FareStructure.create(service: service, fare_type: 2, desc:  "Zone 1: $2.35, Zone 2: $3.30, Zone 3: $4.60, Zone 4: $6.65")
      else
        puts "Fare already exists for " + service.name
      end

      service = Service.find_by_name('Staying Connected')
      if service and service.fare_structures.count == 0
        FareStructure.create(service: service, fare_type: 2, desc: "Registration is required with an annual $60.00 administration fee.")
      else
        puts "Fare already exists for " + service.name
      end

      service = Service.find_by_name('Road to Recovery Program')
      if service and service.fare_structures.count == 0
        FareStructure.create(service: service, fare_type: 0, base: 0.00)
      else
        puts "Fare already exists for " + service.name
      end

      service = Service.find_by_name('Touch a Life')
      if service and service.fare_structures.count == 0
        FareStructure.create(service: service, fare_type: 0, base: 0.00)
      else
        puts "Fare already exists for " + service.name
      end

      service = Service.find_by_name('Area Agency on Aging')
      if service and service.fare_structures.count == 0
        FareStructure.create(service: service, fare_type: 0, base: 0.00)
      else
        puts "Fare already exists for " + service.name
      end

    end # task
  end
end
