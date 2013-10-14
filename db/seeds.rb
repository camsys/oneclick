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
  {name: 'Trips By Day Report', description: 'Displays a chart showing the number of trips generated each day.', view_name: 'generic_report', class_name: 'TripsPerDayReport', active: 1}, 
  {name: 'Failed Trips Report', description: 'Displays a report describing the trips that failed.', view_name: 'trips_report', class_name: 'InvalidTripsReport', active: 1}, 
  {name: 'Rejected Trips Report', description: 'Displays a report showing trips that were rejected by a user.', view_name: 'trips_report', class_name: 'RejectedTripsReport', active: 1} 
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
    disabled = TravelerCharacteristic.create(code: 'disabled', name: 'Disabled', note: 'Is the traveler permanently or temporarily disabled?', datatype: 'bool')
    no_trans = TravelerCharacteristic.create(code: 'no_trans', name: 'No Means of Transportation', note: 'Does the traveler have access to a vehicle?', datatype: 'bool')
    nemt_eligible = TravelerCharacteristic.create(code: 'nemt_eligible', name: 'Medicaid/NEMT Eligible', note: 'Is the traveler Medicaid or NEMT Eligible?', datatype: 'bool')
    ada_eligible = TravelerCharacteristic.create(code: 'ada_eligible', name: 'ADA Paratransit Eligible', note: 'Is the traveler ADA Paratransit eligible?', datatype: 'bool')
    veteran = TravelerCharacteristic.create(code: 'veteran', name: 'Veteran', note: 'Is the traveler a veteran?', datatype: 'bool')
    medicare_eligible = TravelerCharacteristic.create(code: 'medicare_eligible', name: 'Medicare Eligible', note: 'Is the traveler Medicare eligible?', datatype: 'bool')
    low_income = TravelerCharacteristic.create(code: 'low_income', name: 'Low income', note: "Is the traveler classified as low income?", datatype: 'bool')
    date_of_birth = TravelerCharacteristic.create(code: 'date_of_birth', name: 'Date of Birth', note: "What is the traveler's date of birth?", datatype: 'date')
    age = TravelerCharacteristic.create(code: 'age', name: 'Age', note: "What is the traveler's age?", datatype: 'integer')

#Traveler accommodations
    wheelchair_accessible = TravelerAccommodation.create(code: 'wheelchair_acceessible', name: 'Wheelchair accessible', note: 'Does the traveler require a wheelchair accessible service?', datatype: 'bool')
    door_to_door = TravelerAccommodation.create(code: 'door_to_door', name: 'Door-to-door', note: 'Does the traveler require door-to-door service?', datatype: 'bool')
    curb_to_curb = TravelerAccommodation.create(code: 'curb_to_curb', name: 'Curb-to-curb', note: 'Does the traveler require curb-to-curb service?', datatype: 'bool')

#Service types
    paratransit = ServiceType.create(name: 'Paratransit', note: 'This is a general purpose paratransit service.')
    nemt = ServiceType.create(name: 'Non-Emergency Medical Service', note: 'This is a paratransit service only to be used for medical trips.')
    livery = ServiceType.create(name: 'Livery', note: 'Car service for hire.')

#trip_purposes
    work = TripPurpose.create(name: 'Work', note: 'Work-related trip.', active: 1, sort_order: 2)
    training = TripPurpose.create(name: 'Training/Employment', note: 'Employment or training trip.', active: 1, sort_order: 2)
    medical = TripPurpose.create(name: 'Medical', note: 'General medical trip.', active: 1, sort_order: 2)
    dialysis = TripPurpose.create(name: 'Dialysis', note: 'Dialysis appointment.', active: 1, sort_order: 2)
    cancer = TripPurpose.create(name: 'Cancer Treatment', note: 'Trip to receive cancer treatment.', active: 1, sort_order: 2)
    personal = TripPurpose.create(name: 'Personal Errand', note: 'Personal errand/shopping trip.', active: 1, sort_order: 2)
    general = TripPurpose.create(name: 'General Purpose', note: 'General purpose/unspecified purpose.', active: 1, sort_order: 1)

providers = [
    {name: 'Metro Medical Transportation', contact: 'name here', external_id: "esp#2"},
    {name: 'Clayton County Transportation Services', contact: 'John Clayton', external_id: "esp#9"},
    {name: 'Cobb Transportation Services', contact: 'Susan Cobb', external_id: "esp#13"},
    {name: 'Douglas Trans. Services', contact: 'Doug Douglas', external_id: "esp#22"},
    {name: 'ATL Limo', contact: 'Mr. Limo', external_id: "esp#45"},
]

#Create providers and services with custom schedules, eligibility, and accommodations
providers.each do |provider|
  puts "Add/replace provider #{provider[:external_id]}"

  Provider.find_by_external_id(provider[:external_id]).destroy rescue nil
  p = Provider.create! provider
  p.save

  case p.external_id

    when "esp#2" #Metro Medical Transportation
      #Create service
      service = Service.create(name: 'Metro DRT', provider: p, service_type: paratransit, advanced_notice_minutes: 24*60)
      #Add Schedules
      (1..5).each do |n|
        Schedule.create(service: service, start_time:"8:30", end_time: "16:30", day_of_week: n)
      end
      #Trip purpose requirements
      [medical, dialysis, cancer, work, training, personal, general].each do |n|
        ServiceTripPurposeMap.create(service: service, trip_purpose: n, value: 'true')
      end

      #Add geographic restrictions
      ['30309', '30308', '30318', '30332'].each do |z|
        c = GeoCoverage.new(value: z, coverage_type: 'zipcode')
        ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'origin')
      end
        ['Fulton', 'Dekalb'].each do |z|
        c = GeoCoverage.new(value: z, coverage_type: 'county_name')
        ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'destination')
      end

    when "esp#9" #Clayton County Transportation
      #Create service
      service = Service.create(name: 'Clayton NEMT', provider: p, service_type: nemt, advanced_notice_minutes: 14*24*60)
      #Add Schedules
      (1..5).each do |n|
        Schedule.create(service: service, start_time:"8:00", end_time: "14:00", day_of_week: n)
      end
      #Trip Purpose Requirements
      [medical, dialysis, cancer].each do |n|
        ServiceTripPurposeMap.create(service: service, trip_purpose: n, value: 'true')
      end
      #Traveler Characteristics Requirements
      [veteran].each do |n|
        ServiceTravelerCharacteristicsMap.create(service: service, traveler_characteristic: n, value: 'true')
      end
      ServiceTravelerCharacteristicsMap.create(service: service, traveler_characteristic: age, value: '60', value_relationship_id: 4)

      #Traveler Accommodations Provided
      ServiceTravelerAccommodationsMap.create(service: service, traveler_accommodation: wheelchair_accessible, value: 'true')

    when "esp#13" #Cobb Transportation Services
      #Create service
      service = Service.create(name: 'Cobb DRT', provider: p, service_type: paratransit, advanced_notice_minutes: 5*24*60)
      #Add Schedules
      [1,3,5].each do |n|
        Schedule.create(service: service, start_time:"8:00", end_time: "16:00", day_of_week: n)
      end
      #Trip Purpose Requirements
      [medical, dialysis, cancer].each do |n|
        ServiceTripPurposeMap.create(service: service, trip_purpose: n, value: 'true')
      end
      #Traveler Characteristics Requirements
      ServiceTravelerCharacteristicsMap.create(service: service, traveler_characteristic: age, value: '75', value_relationship_id: 4)
      ServiceTravelerCharacteristicsMap.create(service: service, traveler_characteristic: ada_eligible, value: 'true')
      #Traveler Accommodations Provided
      [wheelchair_accessible, door_to_door].each do |n|
        ServiceTravelerAccommodationsMap.create(service: service, traveler_accommodation: n, value: 'true')
      end

    when "esp#22" #Douglas Trans. Service
      #Create service
      service = Service.create(name: 'Douglas DRT', provider: p, service_type: paratransit, advanced_notice_minutes: 2*24*60)
      #Add Schedules
      Schedule.create(service: service, start_time:"00:00", end_time: "23:59", day_of_week: 3)
      #Trip Purpose Requirements
      [medical, dialysis, cancer, work, training, personal, general].each do |n|
        ServiceTripPurposeMap.create(service: service, trip_purpose: n, value: 'true')
      end
      #Traveler Characteristics Requirements
      [nemt_eligible, disabled].each do |n|
        ServiceTravelerCharacteristicsMap.create(service: service, traveler_characteristic: n, value: 'true')
      end
      ServiceTravelerCharacteristicsMap.create(service: service, traveler_characteristic: age, value: '60', value_relationship_id: 4)
      #Traveler Accommodations Provided
      ServiceTravelerAccommodationsMap.create(service: service, traveler_accommodation: wheelchair_accessible, value: 'true')

    when "esp#45" #ATL Limo
      #Create service
      service = Service.create(name: 'Atlanta Town Car Service', provider: p, service_type: livery, advanced_notice_minutes: 60)
      #Add Schedules
      (0..6).each do |n|
        Schedule.create(service: service, start_time:"00:00", end_time: "23:59", day_of_week: n)
      end
      #Trip purpose requirements
      [medical, dialysis, cancer, work, training, personal, general].each do |n|
        ServiceTripPurposeMap.create(service: service, trip_purpose: n, value: 'true')
      end

  end

end