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
      note: 'Are you permanently or temporarily disabled?', 
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
    medicare_eligible = TravelerCharacteristic.create(
      characteristic_type: 'program', 
      code: 'medicare_eligible', 
      name: 'Medicare',
      note: 'Are you eligibe for Medicare?', 
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
    training = TripPurpose.create(
      name: 'Training/Employment', 
      note: 'Employment or training trip.', 
      active: 1, 
      sort_order: 2)
    medical = TripPurpose.create(
      name: 'Medical', 
      note: 'General medical trip.', 
      active: 1, 
      sort_order: 2)
    dialysis = TripPurpose.create(
      name: 'Dialysis', 
      note: 'Dialysis appointment.', 
      active: 1, 
      sort_order: 2)
    cancer = TripPurpose.create(
      name: 'Cancer Treatment', 
      note: 'Trip to receive cancer treatment.', 
      active: 1, 
      sort_order: 2)
    personal = TripPurpose.create(
      name: 'Personal Errand', 
      note: 'Personal errand/shopping trip.', 
      active: 1, 
      sort_order: 2)
    general = TripPurpose.create(
      name: 'General Purpose', 
      note: 'General purpose/unspecified purpose.', 
      active: 1, 
      sort_order: 1)

    #[work, training, medical, dialysis, cancer, personal, general]

providers = [
    {name: 'LIFESPAN Resources, Inc.', contact: 'Lauri Stokes', external_id: "esp#1"},
    {name: 'Fayette County', contact: '', external_id: "esp#6"},
    {name: 'Fulton County Office of Aging', contact: 'Ken Van Hoose', external_id: "esp#7"},
    {name: 'Jewish Family & Career Services', contact: 'Gary Miller', external_id: "esp#3"},
    {name: 'Cobb Senior Services', contact: 'Pam Breeden', external_id: "esp#20"},
    {name: 'Rockdale County Senior Services', contact: 'Jackie Lunsford', external_id: "esp#8"},
    {name: 'Cobb Community Transit (CCT)', contact: 'Gary Blackledge', external_id: "esp#15"},
    {name: 'Transportation Services', contact: 'Nell Childers', external_id: "esp#22"},
    {name: 'Volunteer Transportation Service', contact: 'T.J. McGiffert', external_id: "esp#34"}

]

#Create providers and services with custom schedules, eligibility, and accommodations
providers.each do |provider|
  puts "Add/replace provider #{provider[:external_id]}"

  Provider.find_by_external_id(provider[:external_id]).destroy rescue nil
  p = Provider.create! provider
  p.save

  case p.external_id

    when "esp#1" #LIFESPAN Resources
      #Create service
      service = Service.create(name: 'Volunteer Transportation from', provider: p, service_type: volunteer, advanced_notice_minutes: 14*24*60)
      #Add Schedules
      (2..3).each do |n|
        Schedule.create(service: service, start_time:"9:00", end_time: "16:30", day_of_week: n)
      end
      #Trip purpose requirements
      [medical, dialysis, cancer].each do |n|
        ServiceTripPurposeMap.create(service: service, trip_purpose: n, value: 'true')
      end

      #Add geographic restrictions
      ['30327', '30342', '30319', '30326', '30305', '30324', '30309', '30306', '30363'].each do |z|
        c = GeoCoverage.new(value: z, coverage_type: 'zipcode')
        ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'origin')
      end
      ['30327', '30342', '30319', '30326', '30305', '30324', '30309', '30306', '30363'].each do |z|
        c = GeoCoverage.new(value: z, coverage_type: 'zipcode')
        ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'destination')
      end


      #Traveler Accommodations Requirements
      [door_to_door, curb_to_curb, folding_wheelchair_accessible].each do |n|
        ServiceTravelerAccommodationsMap.create(service: service, traveler_accommodation: n, value: 'true')
      end


    when "esp#6" #Fayette Senior Services
      #Create service #8
      service = Service.create(name: 'Fayette Senior Services', provider: p, service_type: nemt, advanced_notice_minutes: 24*60)
      #Add Schedules
      (1..5).each do |n|
        Schedule.create(service: service, start_time:"8:30", end_time: "17:00", day_of_week: n)
      end

      #Trip Purpose Requirements
      [medical, dialysis, cancer].each do |n|
        ServiceTripPurposeMap.create(service: service, trip_purpose: n, value: 'true')
      end

      #Add geographic restrictions
      ['Fayette'].each do |z|
        c = GeoCoverage.new(value: z, coverage_type: 'county_name')
        ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'origin')
      end

      #Traveler Characteristics Requirements
      ServiceTravelerCharacteristicsMap.create(service: service, traveler_characteristic: age, value: '60', value_relationship_id: 4)

      #Traveler Accommodations Requirements
      [door_to_door, curb_to_curb, driver_assistance_available, motorized_wheelchair_accessible, lift_equipped].each do |n|
        ServiceTravelerAccommodationsMap.create(service: service, traveler_accommodation: n, value: 'true')
      end

    when "esp#7" #Fulton County office of Aging
      #Create service #12
      service = Service.create(name: 'Medical Transportation by', provider: p, service_type: nemt, advanced_notice_minutes: 28*24*60)
      #Add Schedules
      (1..5).each do |n|
        Schedule.create(service: service, start_time:"8:30", end_time: "17:00", day_of_week: n)
      end
      #Trip Purpose Requirements
      [medical, dialysis, cancer].each do |n|
        ServiceTripPurposeMap.create(service: service, trip_purpose: n, value: 'true')
      end

      #Add geographic restrictions
      ['Fulton'].each do |z|
        c = GeoCoverage.new(value: z, coverage_type: 'county_name')
        ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'origin')
      end

      #Traveler Characteristics Requirements
      ServiceTravelerCharacteristicsMap.create(service: service, traveler_characteristic: age, value: '60', value_relationship_id: 4)
      ServiceTravelerCharacteristicsMap.create(service: service, traveler_characteristic: no_trans, value: 'false')

      #Traveler Accommodations Provided
      [folding_wheelchair_accessible, driver_assistance_available, motorized_wheelchair_accessible, curb_to_curb, door_to_door, lift_equipped].each do |n|
        ServiceTravelerAccommodationsMap.create(service: service, traveler_accommodation: n, value: 'true')
      end

      #Create service #11 DARTS
      service = Service.create(name: 'Dial-a-Ride for Seniors (DARTS)', provider: p, service_type: paratransit, advanced_notice_minutes: 24*60)
      #Add Schedules
      (1..5).each do |n|
        Schedule.create(service: service, start_time:"8:30", end_time: "16:30", day_of_week: n)
      end
      #Trip Purpose Requirements
      [work, training, medical, dialysis, cancer, personal, general].each do |n|
        ServiceTripPurposeMap.create(service: service, trip_purpose: n, value: 'true')
      end

      #Add geographic restrictions
      ['Fulton'].each do |z|
        c = GeoCoverage.new(value: z, coverage_type: 'county_name')
        ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'origin')
      end

      #Traveler Characteristics Requirements
      ServiceTravelerCharacteristicsMap.create(service: service, traveler_characteristic: age, value: '55', value_relationship_id: 4)
      ServiceTravelerCharacteristicsMap.create(service: service, traveler_characteristic: no_trans, value: 'false')

      #Traveler Accommodations Provided
      [folding_wheelchair_accessible, driver_assistance_available, door_to_door, curb_to_curb, lift_equipped].each do |n|
        ServiceTravelerAccommodationsMap.create(service: service, traveler_accommodation: n, value: 'true')
      end

    when "esp#3" #Jewish Family & Career Center
                 #Create service #3
      service = Service.create(name: 'JETS Transportation Program', provider: p, service_type: volunteer, advanced_notice_minutes: 24*60)
      #Add Schedules
      (1..5).each do |n|
        Schedule.create(service: service, start_time:"8:30", end_time: "15:00", day_of_week: n)
      end

      #Trip Purpose Requirements
      [medical, dialysis, cancer].each do |n|
        ServiceTripPurposeMap.create(service: service, trip_purpose: n, value: 'true')
      end

      #Add geographic restrictions
      ['30305', '30306', '30308', '30309', '30319', '30324', '30326', '30327', '30328' ,'30329', '30338', '30339', '30340', '30341' ,'30342', '30345', '30063', '30067', '30068', '30084', '30356', '30350', '30060', '30030', '30033', '30084', '30075', '30076', '30022', '30092', '30080'].each do |z|
        c = GeoCoverage.new(value: z, coverage_type: 'zipcode')
        ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'origin')
      end

      ['30305', '30306', '30308', '30309', '30319', '30324', '30326', '30327', '30328' ,'30329', '30338', '30339', '30340', '30341' ,'30342', '30345', '30063', '30067', '30068', '30084', '30356', '30350', '30060', '30030', '30033', '30084', '30075', '30076', '30022', '30092', '30080'].each do |z|
        c = GeoCoverage.new(value: z, coverage_type: 'zipcode')
        ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'destination')
      end

      #Traveler Accommodations Requirements
      [door_to_door, curb_to_curb, driver_assistance_available, folding_wheelchair_accessible, motorized_wheelchair_accessible, lift_equipped].each do |n|
        ServiceTravelerAccommodationsMap.create(service: service, traveler_accommodation: n, value: 'true')
      end

    when "esp#20" #Cobb Senior Services
                 #Create service #36
      service = Service.create(name: 'Cobb Senior Services', provider: p, service_type: paratransit, advanced_notice_minutes: 24*60)
      #Add Schedules
      (1..5).each do |n|
        Schedule.create(service: service, start_time:"8:00", end_time: "14:00", day_of_week: n)
      end

      #Trip Purpose Requirements
      [work, training, medical, dialysis, cancer, personal, general].each do |n|
        ServiceTripPurposeMap.create(service: service, trip_purpose: n, value: 'true')
      end

      #Add geographic restrictions
      ['Cobb'].each do |z|
        c = GeoCoverage.new(value: z, coverage_type: 'county_name')
        ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'origin')
      end

      #Traveler Characteristics Requirements
      ServiceTravelerCharacteristicsMap.create(service: service, traveler_characteristic: age, value: '60', value_relationship_id: 4)

      #Traveler Accommodations Requirements
      [door_to_door, curb_to_curb, driver_assistance_available, folding_wheelchair_accessible, motorized_wheelchair_accessible, lift_equipped].each do |n|
        ServiceTravelerAccommodationsMap.create(service: service, traveler_accommodation: n, value: 'true')
      end

    when "esp#15" #Cobb Community Transit
                    #Create service #29
      service = Service.create(name: 'CCT Paratransit', provider: p, service_type: paratransit, advanced_notice_minutes: 7*24*60)
                    #Add Schedules
      (1..6).each do |n|
        Schedule.create(service: service, start_time:"9:00", end_time: "17:00", day_of_week: n)
      end
      Schedule.create(service: service, start_time:"12:00", end_time: "16:00", day_of_week: 0)

      #Trip Purpose Requirements
      [work, training, medical, dialysis, cancer, personal, general].each do |n|
        ServiceTripPurposeMap.create(service: service, trip_purpose: n, value: 'true')
      end

      #Add geographic restrictions
      ['Cobb'].each do |z|
        c = GeoCoverage.new(value: z, coverage_type: 'county_name')
        ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'origin')
      end

      ['Cobb'].each do |z|
        c = GeoCoverage.new(value: z, coverage_type: 'county_name')
        ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'destination')
      end

      #Traveler Characteristics Requirements
      ServiceTravelerCharacteristicsMap.create(service: service, traveler_characteristic: ada_eligible, value: 'true')

      #Traveler Accommodations Requirements
      [curb_to_curb, folding_wheelchair_accessible, motorized_wheelchair_accessible, lift_equipped].each do |n|
        ServiceTravelerAccommodationsMap.create(service: service, traveler_accommodation: n, value: 'true')
      end

    when "esp#22" #Mountain Area Transportation Services
                  #Create service #41
      service = Service.create(name: 'Cherokee Area', provider: p, service_type: paratransit, advanced_notice_minutes: 24*60)
      #Add Schedules
      (1..5).each do |n|
        Schedule.create(service: service, start_time:"8:30", end_time: "17:00", day_of_week: n)
      end

      #Trip Purpose Requirements
      [work, training, medical, dialysis, cancer, personal, general].each do |n|
        ServiceTripPurposeMap.create(service: service, trip_purpose: n, value: 'true')
      end

      #Add geographic restrictions
      ['Cherokee'].each do |z|
        c = GeoCoverage.new(value: z, coverage_type: 'county_name')
        ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'origin')
      end

      #Traveler Characteristics Requirements
      ServiceTravelerCharacteristicsMap.create(service: service, traveler_characteristic: ada_eligible, value: 'true')

      #Traveler Accommodations Requirements
      [curb_to_curb, door_to_door, folding_wheelchair_accessible, lift_equipped].each do |n|
        ServiceTravelerAccommodationsMap.create(service: service, traveler_accommodation: n, value: 'true')
      end

    when "esp#34" #I care transportation service.
                  #Create Service 55
      service = Service.create(name: 'I Care', provider: p, service_type: volunteer, advanced_notice_minutes: 7*24*60)
      #Add Schedules
      (1..5).each do |n|
        Schedule.create(service: service, start_time:"8:30", end_time: "16:30", day_of_week: n)
      end

      #Trip Purpose Requirements
      [medical, dialysis, cancer].each do |n|
        ServiceTripPurposeMap.create(service: service, trip_purpose: n, value: 'true')
      end

      #Add geographic restrictions
      ['DeKalb'].each do |z|
        c = GeoCoverage.new(value: z, coverage_type: 'county_name')
        ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'origin')
      end

      ['DeKalb'].each do |z|
        c = GeoCoverage.new(value: z, coverage_type: 'county_name')
        ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'destination')
      end

      #Traveler Characteristics Requirements
      ServiceTravelerCharacteristicsMap.create(service: service, traveler_characteristic: disabled, value: 'true')
      ServiceTravelerCharacteristicsMap.create(service: service, traveler_characteristic: age, value: '55', value_relationship_id: 4)

      #Traveler Accommodations Requirements
      [curb_to_curb].each do |n|
        ServiceTravelerAccommodationsMap.create(service: service, traveler_accommodation: n, value: 'true')
      end

    when "esp#8" #Rockdale County Senior Services
                  #Create Service 15
      service = Service.create(name: 'Rockdale County Senior Services', provider: p, service_type: paratransit, advanced_notice_minutes: 7*24*60)
      #Add Schedules
      (1..5).each do |n|
        Schedule.create(service: service, start_time:"7:30", end_time: "11:00", day_of_week: n)
      end

      #Trip Purpose Requirements
      [work, training, medical, dialysis, cancer, personal, general].each do |n|
        ServiceTripPurposeMap.create(service: service, trip_purpose: n, value: 'true')
      end

      #Add geographic restrictions
      ['Rockdale'].each do |z|
        c = GeoCoverage.new(value: z, coverage_type: 'county_name')
        ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'origin')
      end

      ['Rockdale'].each do |z|
        c = GeoCoverage.new(value: z, coverage_type: 'county_name')
        ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'destination')
      end

      #Traveler Characteristics Requirements
      ServiceTravelerCharacteristicsMap.create(service: service, traveler_characteristic: age, value: '60', value_relationship_id: 4)

      #Traveler Accommodations Requirements
      [curb_to_curb, door_to_door, driver_assistance_available, folding_wheelchair_accessible, motorized_wheelchair_accessible, lift_equipped].each do |n|
        ServiceTravelerAccommodationsMap.create(service: service, traveler_accommodation: n, value: 'true')
      end

  end

end