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
  {active: 1, name: 'My house', raw_address: '730 Peachtree St NE, Atlanta, GA 30308'},
  {active: 1, name: 'Atlanta VA Medical Center', raw_address: '1670 Clairmont Rd, Decatur, GA'},
  {active: 1, name: 'Formación Para el Trabajo', raw_address: '239 West Lake Avenue NW, Atlanta, GA 30314'},
  {active: 1, name: 'Atlanta Mission',  raw_address: '239 West Lake Avenue NW, Atlanta, GA 30314'}
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
    lift_equipped = TravelerAccommodation.create(
      code: 'lift_equipped', 
      name: 'Wheelchair lift equipped vehicle.', 
      note: 'Do you need a vehicle with a lift?', 
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
    work = TripPurpose.create(
      name: 'Work', 
      note: 'Work-related trip.', 
      active: 1, 
      sort_order: 2)
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
    senior = TripPurpose.create(
      name: 'Visit Senior Center',
      note: 'Trip to visit Senior Center.',
      active: 1,
      sort_order: 2)
    grocery = TripPurpose.create(
      name: 'Grocery Trip',
      note: 'Grocery shopping trip.',
      active: 1,
      sort_order: 2)


providers = [
    {name: 'BC CS Mass Transit', contact: '', external_id: "1"},
    {name: 'City of Tamarac', contact: '', external_id: "2"},
    {name: 'City of Wilton Manners', contact: ' ', external_id: "3"},
    {name: 'Cooper City Community Services', contact: ' ', external_id: "4"},
    {name: 'City of Miramar', contact: ' ', external_id: "5"},
    {name: 'Southeast Focal Point', contact: ' ', external_id: "6"},
    {name: 'American Cancer Society', contact: ' ', external_id: "7"},
    {name: 'City of Sunrise', contact: ' ', external_id: "8"},
    {name: 'Northwest Focal Point', contact: ' ', external_id: "9"},
    {name: 'City of Lauderdale Lakes', contact: ' ', external_id: "10"}

]

#Create providers and services with custom schedules, eligibility, and accommodations
providers.each do |provider|
  puts "Add/replace provider #{provider[:external_id]}"

  Provider.find_by_external_id(provider[:external_id]).destroy rescue nil
  p = Provider.create! provider
  p.save

  case p.external_id

    when "1" #BC
             #Create service
      service = Service.create(name: 'BC Paratransit', provider: p, service_type: paratransit, advanced_notice_minutes: 24*60)
      #Add Schedules
      (1..5).each do |n|
        Schedule.create(service: service, start_time:"8:00", end_time: "17:00", day_of_week: n)
      end
      #Trip purpose requirements
      [senior, medical, cancer, grocery].each do |n|
        ServiceTripPurposeMap.create(service: service, trip_purpose: n, value: 'true')
      end

      #Add geographic restrictions
      ['Broward'].each do |z|
        c = GeoCoverage.new(value: z, coverage_type: 'county_name')
        ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'origin')
      end
      ['Broward'].each do |z|
        c = GeoCoverage.new(value: z, coverage_type: 'county_name')
        ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'destination')
      end


      #Traveler Characteristics Requirements
      ServiceTravelerCharacteristicsMap.create(service: service, traveler_characteristic: ada_eligible, value: 'true')

      #Traveler Accommodations Requirements
      [motorized_wheelchair_accessible, lift_equipped, door_to_door, driver_assistance_available, folding_wheelchair_accessible].each do |n|
        ServiceTravelerAccommodationsMap.create(service: service, traveler_accommodation: n, value: 'true')
      end


    when "2" #Tamarac

      service = Service.create(name: 'Social Services: Limited Transportation', provider: p, service_type: paratransit, advanced_notice_minutes: 24*60)
      #Add Schedules
      (1..5).each do |n|
        Schedule.create(service: service, start_time:"8:00", end_time: "4:30", day_of_week: n)
      end

      #Trip Purpose Requirements
      [medical,grocery, cancer].each do |n|
        ServiceTripPurposeMap.create(service: service, trip_purpose: n, value: 'true')
      end

      #Add geographic restrictions
      ['33309', '33319', '33320', '33321', '33323', '33351', '33359'].each do |z|
        c = GeoCoverage.new(value: z, coverage_type: 'zipcode')
        ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'origin')
      end

      #Add geographic restrictions
      ['33309', '33319', '33320', '33321', '33323', '33351', '33359'].each do |z|
        c = GeoCoverage.new(value: z, coverage_type: 'zipcode')
        ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'destination')
      end

      #Traveler Characteristics Requirements
      ServiceTravelerCharacteristicsMap.create(service: service, traveler_characteristic: no_trans, value: 'false')

      #Traveler Accommodations Requirements
      [curb_to_curb, folding_wheelchair_accessible].each do |n|
        ServiceTravelerAccommodationsMap.create(service: service, traveler_accommodation: n, value: 'true')
      end

    when "3"   #Wilton Manors

      service = Service.create(name: 'Social Services', provider: p, service_type: paratransit, advanced_notice_minutes: 24*60)
      #Add Schedules
      (1..5).each do |n|
        Schedule.create(service: service, start_time:"8:00", end_time: "17:00", day_of_week: n)
      end
      #Trip Purpose Requirements
      [medical, grocery, cancer].each do |n|
        ServiceTripPurposeMap.create(service: service, trip_purpose: n, value: 'true')
      end

      #Add geographic restrictions
      ['33305', '33311', '33334'].each do |z|
        c = GeoCoverage.new(value: z, coverage_type: 'zipcode')
        ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'origin')
      end

      ['33305', '33311', '33334'].each do |z|
        c = GeoCoverage.new(value: z, coverage_type: 'zipcode')
        ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'destination')
      end

      ServiceTravelerCharacteristicsMap.create(service: service, traveler_characteristic: disabled, value: 'true')

      #Traveler Accommodations Provided
      [folding_wheelchair_accessible, door_to_door].each do |n|
        ServiceTravelerAccommodationsMap.create(service: service, traveler_accommodation: n, value: 'true')
      end

    when "4" #Cooper City

      service = Service.create(name: 'Senior Services Transportation', provider: p, service_type: paratransit, advanced_notice_minutes: 24*60)
      #Add Schedules
      (1..5).each do |n|
        Schedule.create(service: service, start_time:"9:00", end_time: "17:00", day_of_week: n)
      end

      #Trip Purpose Requirements
      [medical, cancer, grocery, senior].each do |n|
        ServiceTripPurposeMap.create(service: service, trip_purpose: n, value: 'true')
      end

      #Add geographic restrictions
      ['33024', '33026', '33328', '33329', '33330'].each do |z|
        c = GeoCoverage.new(value: z, coverage_type: 'zipcode')
        ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'origin')
      end

      ['Broward'].each do |z|
        c = GeoCoverage.new(value: z, coverage_type: 'county_name')
        ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'destination')
      end

      #Traveler Characteristics Requirements
      ServiceTravelerCharacteristicsMap.create(service: service, traveler_characteristic: age, value: '60', value_relationship_id: 4)

      #Traveler Accommodations Requirements
      [door_to_door, folding_wheelchair_accessible].each do |n|
        ServiceTravelerAccommodationsMap.create(service: service, traveler_accommodation: n, value: 'true')
      end

    when "5" #City of Miramar
             #
      service = Service.create(name: 'Senior Center', provider: p, service_type: paratransit, advanced_notice_minutes: 24*60)
      #Add Schedules
      (1..5).each do |n|
        Schedule.create(service: service, start_time:"8:00", end_time: "16:30", day_of_week: n)
      end

      #Trip Purpose Requirements
      [senior, cancer, medical, grocery].each do |n|
        ServiceTripPurposeMap.create(service: service, trip_purpose: n, value: 'true')
      end

      #Add geographic restrictions
      ['33023', '33025', '33027', '33029'].each do |z|
        c = GeoCoverage.new(value: z, coverage_type: 'zipcode')
        ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'origin')
      end

      ['33023', '33025', '33027', '33029'].each do |z|
        c = GeoCoverage.new(value: z, coverage_type: 'zipcode')
        ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'destination')
      end

      #Traveler Characteristics Requirements
      ServiceTravelerCharacteristicsMap.create(service: service, traveler_characteristic: age, value: '60', value_relationship_id: 4)

      #Traveler Accommodations Requirements
      [door_to_door, folding_wheelchair_accessible].each do |n|
        ServiceTravelerAccommodationsMap.create(service: service, traveler_accommodation: n, value: 'true')
      end

    when "6" # SE Focal Point
             #
      service = Service.create(name: 'Joseph Meyerhoff Senior Center', provider: p, service_type: paratransit, advanced_notice_minutes: 7*24*60)
      #Add Schedules
      (1..5).each do |n|
        Schedule.create(service: service, start_time:"8:00", end_time: "16:00", day_of_week: n)
      end

      #Trip Purpose Requirements
      [grocery].each do |n|
        ServiceTripPurposeMap.create(service: service, trip_purpose: n, value: 'true')
      end

      #Add geographic restrictions
      ['33028', '33027', '33330', '33325', '33324', '33313', '33311', '33334', '33308', '33306', '33305', '33304', '33301', '33316', '33315', '33312', '33004', '33317', '33314', '33313', '33312', '333026', '33024', '33004', '33025', '33021', '33023', '33020', '33009', '33019'].each do |z|
        c = GeoCoverage.new(value: z, coverage_type: 'zipcode')
        ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'origin')
      end

      ['33028', '33027', '33330', '33325', '33324', '33313', '33311', '33334', '33308', '33306', '33305', '33304', '33301', '33316', '33315', '33312', '33004', '33317', '33314', '33313', '33312', '333026', '33024', '33004', '33025', '33021', '33023', '33020', '33009', '33019'].each do |z|
        c = GeoCoverage.new(value: z, coverage_type: 'zipcode')
        ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'destination')
      end

      #Traveler Characteristics Requirements
      ServiceTravelerCharacteristicsMap.create(service: service, traveler_characteristic: age, value: '60', value_relationship_id: 4)

      #Traveler Accommodations Requirements
      [curb_to_curb, folding_wheelchair_accessible].each do |n|
        ServiceTravelerAccommodationsMap.create(service: service, traveler_accommodation: n, value: 'true')
      end

    when "7" #American Cancer Society

      service = Service.create(name: 'Road to Recovery', provider: p, service_type: paratransit, advanced_notice_minutes: 24*60)
      #Add Schedules
      (1..5).each do |n|
        Schedule.create(service: service, start_time:"9:00", end_time: "17:00", day_of_week: n)
      end

      #Trip Purpose Requirements
      [cancer].each do |n|
        ServiceTripPurposeMap.create(service: service, trip_purpose: n, value: 'true')
      end

      #Add geographic restrictions
      ['broward'].each do |z|
        c = GeoCoverage.new(value: z, coverage_type: 'county_name')
        ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'origin')
      end

      #Add geographic restrictions
      ['broward'].each do |z|
        c = GeoCoverage.new(value: z, coverage_type: 'county_name')
        ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'destination')
      end

      #Traveler Characteristics Requirements
      ServiceTravelerCharacteristicsMap.create(service: service, traveler_characteristic: no_trans, value: 'false')

      #Traveler Accommodations Requirements
      [curb_to_curb, folding_wheelchair_accessible].each do |n|
        ServiceTravelerAccommodationsMap.create(service: service, traveler_accommodation: n, value: 'true')
      end

    when "8" #City of Sunrise

      service = Service.create(name: 'Special & Community Support Services', provider: p, service_type: paratransit, advanced_notice_minutes: 24*60)
      #Add Schedules
      (1..5).each do |n|
        Schedule.create(service: service, start_time:"8:00", end_time: "17:00", day_of_week: n)
      end

      #Trip Purpose Requirements
      [medical, cancer].each do |n|
        ServiceTripPurposeMap.create(service: service, trip_purpose: n, value: 'true')
      end

      #Add geographic restrictions
      ['33304', '33313', '33319', '33321', '33322', '33323', '33325', '33326', '33338', '33345', '33351', '33355'].each do |z|
        c = GeoCoverage.new(value: z, coverage_type: 'zipcode')
        ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'origin')
      end

      ['broward'].each do |z|
        c = GeoCoverage.new(value: z, coverage_type: 'county_name')
        ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'destination')
      end

      #Traveler Characteristics Requirements
      ServiceTravelerCharacteristicsMap.create(service: service, traveler_characteristic: no_trans, value: 'false')
      ServiceTravelerCharacteristicsMap.create(service: service, traveler_characteristic: age, value: '62', value_relationship_id: 4)

      #Traveler Accommodations Requirements
      [curb_to_curb, folding_wheelchair_accessible].each do |n|
        ServiceTravelerAccommodationsMap.create(service: service, traveler_accommodation: n, value: 'true')
      end

    when "9" #Northwest Focal Center

      service = Service.create(name: 'Senior Medical Transportation', provider: p, service_type: paratransit, advanced_notice_minutes: 2*24*60)
      #Add Schedules
      (1..5).each do |n|
        Schedule.create(service: service, start_time:"8:00", end_time: "17:00", day_of_week: n)
      end

      #Trip Purpose Requirements
      [medical, cancer].each do |n|
        ServiceTripPurposeMap.create(service: service, trip_purpose: n, value: 'true')
      end

      #Add geographic restrictions
      ['33063', '33065', '33093', '33068', '33067', '33073'].each do |z|
        c = GeoCoverage.new(value: z, coverage_type: 'zipcode')
        ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'origin')
      end

      ['33063', '33065', '33093', '33068', '33067', '33073'].each do |z|
        c = GeoCoverage.new(value: z, coverage_type: 'zipcode')
        ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'destination')
      end

      #Traveler Characteristics Requirements
      ServiceTravelerCharacteristicsMap.create(service: service, traveler_characteristic: age, value: '60', value_relationship_id: 4)

      #Traveler Accommodations Requirements
      [curb_to_curb, folding_wheelchair_accessible].each do |n|
        ServiceTravelerAccommodationsMap.create(service: service, traveler_accommodation: n, value: 'true')
      end

    when "10" #City of Luaderdale Lakes

      service = Service.create(name: 'Senior Transport', provider: p, service_type: paratransit, advanced_notice_minutes: 3*24*60)
      #Add Schedules
      (1..5).each do |n|
        Schedule.create(service: service, start_time:"8:00", end_time: "17:00", day_of_week: n)
      end

      #Trip Purpose Requirements
      [grocery, general, senior, medical, cancer].each do |n|
        ServiceTripPurposeMap.create(service: service, trip_purpose: n, value: 'true')
      end

      #Add geographic restrictions
      ['33063', '33068', '33067', '33073'].each do |z|
        c = GeoCoverage.new(value: z, coverage_type: 'zipcode')
        ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'origin')
      end

      ['33063', '33068', '33067', '33073'].each do |z|
        c = GeoCoverage.new(value: z, coverage_type: 'zipcode')
        ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'destination')
      end

      #Traveler Characteristics Requirements
      ServiceTravelerCharacteristicsMap.create(service: service, traveler_characteristic: age, value: '60', value_relationship_id: 4)

      #Traveler Accommodations Requirements
      [curb_to_curb, folding_wheelchair_accessible].each do |n|
        ServiceTravelerAccommodationsMap.create(service: service, traveler_accommodation: n, value: 'true')
      end


      service = Service.create(name: 'Disabled Transport', provider: p, service_type: paratransit, advanced_notice_minutes: 3*24*60)
      #Add Schedules
      (1..5).each do |n|
        Schedule.create(service: service, start_time:"9:00", end_time: "12:00", day_of_week: n)
      end

      #Trip Purpose Requirements
      [grocery, general, senior, medical, cancer].each do |n|
        ServiceTripPurposeMap.create(service: service, trip_purpose: n, value: 'true')
      end

      #Add geographic restrictions
      ['33063', '33068', '33067', '33073'].each do |z|
        c = GeoCoverage.new(value: z, coverage_type: 'zipcode')
        ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'origin')
      end

      ['33063', '33068', '33067', '33073'].each do |z|
        c = GeoCoverage.new(value: z, coverage_type: 'zipcode')
        ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'destination')
      end

      #Traveler Characteristics Requirements
      ServiceTravelerCharacteristicsMap.create(service: service, traveler_characteristic: disabled, value: 'true')

      #Traveler Accommodations Requirements
      [curb_to_curb, folding_wheelchair_accessible].each do |n|
        ServiceTravelerAccommodationsMap.create(service: service, traveler_accommodation: n, value: 'true')
      end


  end

end

