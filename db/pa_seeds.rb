#encoding: utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
# Environment variables (ENV['...']) are set in the file config/application.yml.
# See http://railsapps.github.io/rails-environment-variables.html
places = [ 
  {active: 1, name: 'My house', raw_address: '100 Dewey Street, West York, PA, 17404'},
  {active: 1, name: 'VA York Clinic', raw_address: '2251 Eastern Blvd, York, PA 17402'},
  {active: 1, name: "YMCA Men's Emergency Shelter", raw_address: '310 West Philadelphia Street, York, PA, 17401'}
  ]
users = [
  {first_name: 'Denis', last_name: 'Haskin', email: 'dhaskin@camsys.com'},
  {first_name: 'Derek', last_name: 'Edwards', email: 'dedwards@camsys.com'},
  {first_name: 'Eric', last_name: 'Ziering', email: 'eziering@camsys.com'},
  {first_name: 'Galina', last_name: 'Dymkova', email: 'gdymkova@camsys.com'},
  {first_name: 'Aaron', last_name: 'Magil', email: 'amagil@camsys.com'},
  {first_name: 'Julian', last_name: 'Ray', email: 'jray@camsys.com'},
  {first_name: 'sys', last_name: 'admin', email: 'email@camsys.com'},
]
roles = [
  {name: 'admin'},
  {name: 'agent'},
  {name: 'agent_admin'},
]
trip_statuses = [
  {active: 1, name: 'New'},
  {active: 1, name: 'In Progress'},
  {active: 1, name: 'Completed'},
  {active: 1, name: 'Errored'},
]
modes = [
  {active: 1, name: 'Transit'},
  {active: 1, name: 'Paratransit'},
  {active: 1, name: 'Taxi'},
  {active: 1, name: 'Rideshare'},
]
reports = [
  {name: 'Trips Created', description: 'Displays a chart showing the number of trips created each day.', view_name: 'generic_report', class_name: 'TripsCreatedByDayReport', active: 1}, 
  {name: 'Trips Scheduled', description: 'Displays a chart showing the number of trips scheduled for each day.', view_name: 'generic_report', class_name: 'TripsScheduledByDayReport', active: 1}, 
  {name: 'Failed Trips', description: 'Displays a report describing the trips that failed.', view_name: 'trips_report', class_name: 'InvalidTripsReport', active: 1}, 
  {name: 'Rejected Trips', description: 'Displays a report showing trips that were rejected by a user.', view_name: 'trips_report', class_name: 'RejectedTripsReport', active: 1} 
]
relationship_statuses = [
  {name: 'Requested'},
  {name: 'Pending'},
  {name: 'Confirmed'},
  {name: 'Denied'},
  {name: 'Revoked'},
  {name: 'Hidden'},
]

# load the modes
modes.each do |mode|
  m = Mode.new(mode)
  m.save!
end

# load the trip statuses
trip_statuses.each do |status|
  t = TripStatus.new(status)
  t.save!
end

# load the relationship statuses
relationship_statuses.each do |status|
  t = RelationshipStatus.new(status)
  t.save!
end

users.each do |user|
  puts "Add/replace user #{user[:email]}"
  User.find_by_email(user[:email]).destroy rescue nil
  u = User.create! user.merge({password: 'welcome1'})
  up = UserProfile.new
  up.user = u
  up.save!
  places.each do |place|
    p = Place.new(place)
    p.creator = u
    p.geocode
    u.places << p
    begin
      u.save!
    rescue Exception => e
      puts e.inspect
      puts u.errors.inspect
      u.places.each do |pl|
        puts pl.errors.inspect
      end
    end
  end
  Mode.all.each do |mode|
    ump = UserModePreference.new
    ump.user = u
    ump.mode = mode
    ump.save!
  end
end

# load the roles
roles.each do |role| 
  r = Role.new(role)
  r.save!
end
u = User.find_by_email('email@camsys.com')
u.add_role 'admin'
u.save!

# load the reports
reports.each do |rep|
  r = Report.new(rep)
  r.save!
end

##### Eligibility Seeds #####

#Traveler characteristics

    disabled = TravelerCharacteristic.create(
      characteristic_type: 'personal_factor', 
      code: 'disabled',
      name: 'Disabled', 
      note: 'Do you have a permanent or temporary disability?',
      datatype: 'bool')
    no_trans = TravelerCharacteristic.create(
      characteristic_type: 'personal_factor', 
      code: 'no_trans', 
      name: 'No Means of Transportation', 
      note: 'Do you own or have access to a personal vehicle?', 
      datatype: 'bool')
    nemt_eligible = TravelerCharacteristic.create(
      characteristic_type: 'program', 
      code: 'nemt_eligible', 
      name: 'Medicaid',
      note: 'Are you eligible for Medicaid?', 
      datatype: 'bool')
    ada_eligible = TravelerCharacteristic.create(
      characteristic_type: 'program', 
      code: 'ada_eligible', 
      name: 'ADA Paratransit',
      note: 'Are you eligible for ADA paratransit?', 
      datatype: 'bool')
    matp = TravelerCharacteristic.create(
      characteristic_type: 'program',
      code: 'matp',
      name: 'Medical Assistance Transportation Program',
      note: 'Do you have a Medical Assistance Access Card?',
      datatype: 'bool')
    veteran = TravelerCharacteristic.create(
      characteristic_type: 'personal_factor', 
      code: 'veteran', 
      name: 'Veteran', 
      note: 'Are you a military veteran?', 
      datatype: 'bool')
    low_income = TravelerCharacteristic.create(
      characteristic_type: 'personal_factor', 
      code: 'low_income', 
      name: 'Low income', 
      note: "Are you low income?", 
      datatype: 'disabled')
    date_of_birth = TravelerCharacteristic.create(
      characteristic_type: 'personal_factor', 
      code: 'date_of_birth', 
      name: 'Date of Birth', 
      note: "What is your date of birth?", 
      datatype: 'date')
    age = TravelerCharacteristic.create(
      characteristic_type: 'personal_factor', 
      code: 'age', 
      name: 'Age', 
      note: "What is the traveler's age?", 
      datatype: 'integer')
    walk_distance = TravelerCharacteristic.create(
      characteristic_type: 'personal_factor', 
      code: 'walk_distance', 
      name: 'Walk distance', 
      note: 'Are you able to comfortably walk for 5, 10, 15, 20, 25, 30 minutes?', 
      datatype: 'disabled')
    

#Traveler accommodations
    folding_wheelchair_accessible = TravelerAccommodation.create(
      code: 'folding_wheelchair_acceessible', 
      name: 'Folding wheelchair accessible.', 
      note: 'Do you need a vehicle that has space for a folding wheelchair?', 
      datatype: 'bool')
    motorized_wheelchair_accessible = TravelerAccommodation.create(
      code: 'motorized_wheelchair_accessible', 
      name: 'Motorized wheelchair accessible.', 
      note: 'Do you need a vehicle than has space for a motorized wheelchair?', 
      datatype: 'bool')
    door_to_door = TravelerAccommodation.create(
      code: 'door_to_door', 
      name: 'Door-to-door', 
      note: 'Do you need assistance getting to your front door?',
      datatype: 'bool')
    curb_to_curb = TravelerAccommodation.create(
      code: 'curb_to_curb', 
      name: 'Curb-to-curb', 
      note: 'Do you need delivery to the curb in front of your home?', 
      datatype: 'bool')
    driver_assistance_available = TravelerAccommodation.create(
      code: 'driver_assistance_available', 
      name: 'Driver assistance available.', 
      note: 'Do you need personal assistance from the driver?', 
      datatype: 'bool')


#Service types
    paratransit = ServiceType.create(
      name: 'Paratransit', 
      note: 'This is a general purpose paratransit service.')
    volunteer = ServiceType.create(
      name: 'Volunteer', 
      note: '')
    nemt = ServiceType.create(
      name: 'Non-Emergency Medical Service', 
      note: 'This is a paratransit service only to be used for medical trips.')
    livery = ServiceType.create(
      name: 'Livery', 
      note: 'Car service for hire.')

#trip_purposes

    medical = TripPurpose.create(
      name: 'Medical', 
      note: 'General medical trip.', 
      active: 1, 
      sort_order: 2)
    cancer = TripPurpose.create(
      name: 'Cancer Treatment', 
      note: 'Trip to receive cancer treatment.', 
      active: 1, 
      sort_order: 2)
    general = TripPurpose.create(
      name: 'General Purpose', 
      note: 'General purpose/unspecified purpose.', 
      active: 1, 
      sort_order: 1)
    grocery = TripPurpose.create(
      name: 'Grocery Trip',
      note: 'Grocery shopping trip.',
      active: 1,
      sort_order: 2)


providers = [
    {name: 'Rabbit Transit', contact: '', external_id: "1"},
    {name: 'Faith in Action Network', contact: '', external_id: "2"},
    {name: 'American Cancer Society', contact: '', external_id: "3"},
    {name: 'Lutheran Social Services', contact: '', external_id: "4"},
    {name: 'York County Area Agency on Aging', contact: '', external_id:  "5"}

]

#Create providers and services with custom schedules, eligibility, and accommodations
providers.each do |provider|
  puts "Add/replace provider #{provider[:external_id]}"

  Provider.find_by_external_id(provider[:external_id]).destroy rescue nil
  p = Provider.create! provider
  p.save

  case p.external_id

    when "1" #Rabbit Transit

      #Create service Senior Shared Ride
      service = Service.create(name: 'Senior Shared Ride', provider: p, service_type: paratransit, advanced_notice_minutes: 24*60)
      #Add Schedules
      (1..5).each do |n|
        Schedule.create(service: service, start_time:"5:45", end_time: "23:30", day_of_week: n)
      end
      Schedule.create(service: service, start_time:"7:15", end_time: "21:45", day_of_week: 6)
      Schedule.create(service: service, start_time:"9:15", end_time: "18:00", day_of_week: 0)
      #Trip purpose requirements
      [general, medical, cancer, grocery].each do |n|
        ServiceTripPurposeMap.create(service: service, trip_purpose: n, value: 'true')
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

      #Traveler Characteristics Requirements
      ServiceTravelerCharacteristicsMap.create(service: service, traveler_characteristic: age, value: '65', value_relationship_id: 4)

      #Traveler Accommodations Requirements
      [motorized_wheelchair_accessible, folding_wheelchair_accessible, curb_to_curb].each do |n|
        ServiceTravelerAccommodationsMap.create(service: service, traveler_accommodation: n, value: 'true')
      end

      #Shared Ride for Ages 60-64
      service = Service.create(name: 'Shared Ride for Ages 60-64', provider: p, service_type: paratransit, advanced_notice_minutes: 24*60)
      #Add Schedules
      (1..5).each do |n|
        Schedule.create(service: service, start_time:"5:45", end_time: "23:30", day_of_week: n)
      end
      Schedule.create(service: service, start_time:"7:15", end_time: "21:45", day_of_week: 6)
      Schedule.create(service: service, start_time:"9:15", end_time: "18:00", day_of_week: 0)
      #Trip purpose requirements
      [medical, cancer].each do |n|
        ServiceTripPurposeMap.create(service: service, trip_purpose: n, value: 'true')
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

      #Traveler Characteristics Requirements
      ServiceTravelerCharacteristicsMap.create(service: service, traveler_characteristic: age, value: '60', value_relationship_id: 4)
      ServiceTravelerCharacteristicsMap.create(service: service, traveler_characteristic: age, value: '64', value_relationship_id: 6)

      #Traveler Accommodations Requirements
      [motorized_wheelchair_accessible, folding_wheelchair_accessible, curb_to_curb].each do |n|
        ServiceTravelerAccommodationsMap.create(service: service, traveler_accommodation: n, value: 'true')
      end

      #Medical Assistance Transportation Program
      service = Service.create(name: 'Medical Assistance Transportation Program', provider: p, service_type: paratransit, advanced_notice_minutes: 24*60)
      #Add Schedules
      (1..5).each do |n|
        Schedule.create(service: service, start_time:"5:45", end_time: "23:30", day_of_week: n)
      end
      Schedule.create(service: service, start_time:"7:15", end_time: "21:45", day_of_week: 6)
      Schedule.create(service: service, start_time:"9:15", end_time: "18:00", day_of_week: 0)
      #Trip purpose requirements
      [medical, cancer].each do |n|
        ServiceTripPurposeMap.create(service: service, trip_purpose: n, value: 'true')
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
      ['York', 'Adams'].each do |z|
        c = GeoCoverage.new(value: z, coverage_type: 'county_name')
        ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'residence')
      end

      #Traveler Characteristics Requirements
      ServiceTravelerCharacteristicsMap.create(service: service, traveler_characteristic: matp, value: 'true')

      #Traveler Accommodations Requirements
      [motorized_wheelchair_accessible, folding_wheelchair_accessible, curb_to_curb].each do |n|
        ServiceTravelerAccommodationsMap.create(service: service, traveler_accommodation: n, value: 'true')
      end

      #ADA Complementary
      service = Service.create(name: 'ADA Complementary Service', provider: p, service_type: paratransit, advanced_notice_minutes: 24*60)
      #Add Schedules
      (1..5).each do |n|
        Schedule.create(service: service, start_time:"5:45", end_time: "23:30", day_of_week: n)
      end
      Schedule.create(service: service, start_time:"7:15", end_time: "21:45", day_of_week: 6)
      Schedule.create(service: service, start_time:"9:15", end_time: "18:00", day_of_week: 0)
      #Trip purpose requirements
      [medical, cancer, general, grocery].each do |n|
        ServiceTripPurposeMap.create(service: service, trip_purpose: n, value: 'true')
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

      #Traveler Characteristics Requirements
      ServiceTravelerCharacteristicsMap.create(service: service, traveler_characteristic: ada_eligible, value: 'true')

      #Traveler Accommodations Requirements
      [motorized_wheelchair_accessible, folding_wheelchair_accessible, curb_to_curb].each do |n|
        ServiceTravelerAccommodationsMap.create(service: service, traveler_accommodation: n, value: 'true')
      end

      #Service for Persons with Disabilities
      service = Service.create(name: 'Service for Persons with Disabilities', provider: p, service_type: paratransit, advanced_notice_minutes: 24*60)
      #Add Schedules
      (1..5).each do |n|
        Schedule.create(service: service, start_time:"5:45", end_time: "23:30", day_of_week: n)
      end
      Schedule.create(service: service, start_time:"7:15", end_time: "21:45", day_of_week: 6)
      Schedule.create(service: service, start_time:"9:15", end_time: "18:00", day_of_week: 0)
      #Trip purpose requirements
      [medical, cancer, general, grocery].each do |n|
        ServiceTripPurposeMap.create(service: service, trip_purpose: n, value: 'true')
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

      #Traveler Characteristics Requirements
      ServiceTravelerCharacteristicsMap.create(service: service, traveler_characteristic: disabled, value: 'true')

      #Traveler Accommodations Requirements
      [motorized_wheelchair_accessible, folding_wheelchair_accessible, curb_to_curb].each do |n|
        ServiceTravelerAccommodationsMap.create(service: service, traveler_accommodation: n, value: 'true')
      end

    when "2" #Faith in Action Network

      service = Service.create(name: 'Staying Connected', provider: p, service_type: paratransit, advanced_notice_minutes: 7*24*60)
      #Add Schedules
      (1..4).each do |n|
        Schedule.create(service: service, start_time:"9:00", end_time: "16:00", day_of_week: n)
      end

      #Trip Purpose Requirements
      [medical, grocery, cancer, general].each do |n|
        ServiceTripPurposeMap.create(service: service, trip_purpose: n, value: 'true')
      end

      #Add geographic restrictions
      ['York'].each do |z|
        c = GeoCoverage.new(value: z, coverage_type: 'county_name')
        ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'origin')
      end

      #Add geographic restrictions
      ['York'].each do |z|
        c = GeoCoverage.new(value: z, coverage_type: 'county_name')
        ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'destination')
      end

      #Traveler Characteristics Requirements
      ServiceTravelerCharacteristicsMap.create(service: service, traveler_characteristic: age, value: '60', value_relationship_id: 4)

      #Traveler Accommodations Requirements
      [curb_to_curb, folding_wheelchair_accessible].each do |n|
        ServiceTravelerAccommodationsMap.create(service: service, traveler_accommodation: n, value: 'true')
      end

    when "3" #American Cancer Society

      service = Service.create(name: 'Road to Recovery Program', provider: p, service_type: paratransit, advanced_notice_minutes: 24*60)
      #Add Schedules
      (1..5).each do |n|
        Schedule.create(service: service, start_time:"8:30", end_time: "16:30", day_of_week: n)
      end

      #Trip Purpose Requirements
      [cancer].each do |n|
        ServiceTripPurposeMap.create(service: service, trip_purpose: n, value: 'true')
      end

      #Add geographic restrictions
      ['York', 'Adams'].each do |z|
        c = GeoCoverage.new(value: z, coverage_type: 'county_name')
        ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'origin')
      end

      #Add geographic restrictions
      ['York', 'Adams'].each do |z|
        c = GeoCoverage.new(value: z, coverage_type: 'county_name')
        ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'destination')
      end


      #Traveler Accommodations Requirements
      [curb_to_curb, folding_wheelchair_accessible].each do |n|
        ServiceTravelerAccommodationsMap.create(service: service, traveler_accommodation: n, value: 'true')
      end

    when "4" #Luthern Social Services of South Central PA

      service = Service.create(name: 'Touch a Life', provider: p, service_type: paratransit, advanced_notice_minutes: 5*24*60)
      #Add Schedules
      (1..5).each do |n|
        Schedule.create(service: service, start_time:"8:30", end_time: "16:30", day_of_week: n)
      end

      #Trip Purpose Requirements
      [cancer, medical, general, grocery].each do |n|
        ServiceTripPurposeMap.create(service: service, trip_purpose: n, value: 'true')
      end

      #Add geographic restrictions
      ['York', 'Adams', 'Franklin', 'Fulton'].each do |z|
        c = GeoCoverage.new(value: z, coverage_type: 'county_name')
        ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'origin')
      end

      #Add geographic restrictions
      ['York', 'Adams', 'Franklin', 'Fulton'].each do |z|
        c = GeoCoverage.new(value: z, coverage_type: 'county_name')
        ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'destination')
      end


      #Traveler Accommodations Requirements
      [curb_to_curb, folding_wheelchair_accessible].each do |n|
        ServiceTravelerAccommodationsMap.create(service: service, traveler_accommodation: n, value: 'true')
      end

    when "5" #Area Agency on Aging

      service = Service.create(name: 'Area Agency on Aging', provider: p, service_type: paratransit, advanced_notice_minutes: 5*24*60)
      #Add Schedules
      (1..5).each do |n|
        Schedule.create(service: service, start_time:"8:00", end_time: "16:30", day_of_week: n)
      end

      #Trip Purpose Requirements
      [cancer, medical, general, grocery].each do |n|
        ServiceTripPurposeMap.create(service: service, trip_purpose: n, value: 'true')
      end

      #Add geographic restrictions
      ['York', 'Adams', 'Franklin', 'Fulton'].each do |z|
        c = GeoCoverage.new(value: z, coverage_type: 'county_name')
        ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'origin')
      end

      #Add geographic restrictions
      ['York', 'Adams', 'Franklin', 'Fulton'].each do |z|
        c = GeoCoverage.new(value: z, coverage_type: 'county_name')
        ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'destination')
      end

      #Traveler Characteristics Required
      ServiceTravelerCharacteristicsMap.create(service: service, traveler_characteristic: age, value: '60', value_relationship_id: 4)

      #Traveler Accommodations Requirements
      [curb_to_curb, folding_wheelchair_accessible].each do |n|
        ServiceTravelerAccommodationsMap.create(service: service, traveler_accommodation: n, value: 'true')
      end


  end

end

