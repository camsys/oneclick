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
places = [ {name: 'My house', raw_address: '730 Peachtree St NE, Atlanta, GA 30308'},
  {name: 'Atlanta VA Medical Center', raw_address: '1670 Clairmont Rd, Decatur, GA'},
  {name: 'Formación Para el Trabajo', raw_address: '239 West Lake Avenue NW, Atlanta, GA 30314'},
  {name: 'Atlanta Mission',  raw_address: '239 West Lake Avenue NW, Atlanta, GA 30314'}
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
  {id: 1, name: 'Admin'},
  {id: 2, name: 'Agent'},
  {id: 3, name: 'Agent_Admin'},  
]
trip_statuses = [
  {id: 1, active: 1, name: 'New'},
  {id: 2, active: 1, name: 'In Progress'},
  {id: 3, active: 1, name: 'Completed'},  
  {id: 4, active: 1, name: 'Errored'},  
]
modes = [
  {id: 1, active: 1, name: 'Transit'},
  {id: 2, active: 1, name: 'Paratransit'},
  {id: 3, active: 1, name: 'Taxi'},  
]
reports = [
  {name: 'Trips By Day Report', description: 'Displays a chart showing the number of trips generated each day.', view_name: 'generic_report', class_name: 'TripsPerDayReport', active: 1}, 
  {name: 'Failed Trips Report', description: 'Displays a report describing the trips that failed.', view_name: 'trips_report', class_name: 'InvalidTripsReport', active: 1}, 
  {name: 'Rejected Trips Report', description: 'Displays a report showing trips that were rejected by a user.', view_name: 'trips_report', class_name: 'RejectedTripsReport', active: 1} 
]
relationship_statuses = [
  {id: 1, name: 'Requested'},
  {id: 2, name: 'Pending'},
  {id: 3, name: 'Confirmed'},
  {id: 4, name: 'Denied'},  
  {id: 5, name: 'Revoked'},  
  {id: 6, name: 'Hidden'},  
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
    p.geocode
    u.places << p
    begin
      u.save!
    rescue Exception => e
      puts e.inspect
      puts u.errors.inspect
      u.places.each do |p|
        puts p.errors.inspect
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
u.add_role 'Admin'
u.save!

# load the reports
reports.each do |rep|
  r = Report.new(rep)
  r.save!
end

##### Eligibility Seeds #####

traveler_characteristics = [
    {id:1, name: 'Veteran', note: 'Is the traveler a veteran?', datatype: 'bool'},
    {id:2, name: 'Disabled', note: 'Is the traveler disabled?', datatype: 'bool'},
    {id:3, name: 'Medicaid/NEMT Elgigible', note: 'Is the traveler Medicaid/NEMT Eligible?', datatype: 'bool'},
    {id:4, name: 'Date of Birth', note: '', datatype: 'date'},
    {id:5, name: 'Age', note: '', datatype: 'integer'},
]

traveler_accommodations = [
    {id:1, name: 'Wheelchair Accessible', note: 'The passenger requires a wheelchair accessible service.', datatype: 'bool'},
    {id:2, name: 'Door-to-door', note: 'The passenger requires door-to-door service.', datatype: 'bool'},
    {id:3, name: 'Curb-to-curb', note: 'The passenger requires curb-to-curb service.', datatype: 'bool'},
]

providers = [
    {id: 1, name: 'Cobb Community Transit', contact: 'Contact Name', external_id: "esp#24"},
    {id: 2, name: 'Metro Atlanta Rapid Transit Authority', contact: 'MARTA Contact Name', external_id: "esp#35"},
    {id: 3, name: "Dept. of Veterans Affairs", contact: 'Dave Jones', external_id: "esp#64"},
]

service_types = [
    {id: 1, name: 'Paratransit', note: 'This is a general purpose paratransit service.'},
    {id: 2, name: 'Non-Emergency Medical Service', note: 'This is a paratransit service only to be used for medical trips.'},
    {id: 3, name: 'NEMT Broker', note: 'This service will arrange trips for non-emergency medical reasons, but does not provide trips directly.'},
]

services = [
    {id: 1, name: 'CCT Paratransit', provider_id: 1, service_type_id: 1, advanced_notice_minutes: 24*60},
    {id: 2, name: 'MARTA Mobility', provider_id: 2, service_type_id: 1, advanced_notice_minutes: 48*60},
    {id: 3, name: 'VA NEMT Service', provider_id: 3, service_type_id: 2, advanced_notice_minutes: 120},
    {id: 4, name: 'CCT NEMT Service', provider_id: 1, service_type_id: 2, advanced_notice_minutes: 120},
]

service_traveler_characteristics_map = [
    {service_id: 1, characteristic_id: 2, value: 'true'},  #CCT Paratransit Traveler must be disabled
    {service_id: 1, characteristic_id: 5, value: '65', value_relationship_id: 3}, #CCT Paratransit Traveler's age must be >= 65
    {service_id: 2, characteristic_id: 2, value: 'true'},
    {service_id: 2, characteristic_id: 5, value: '100', value_relationship_id: 5},
    {service_id: 3, characteristic_id: 1, value: 'true'},
    {service_id: 3, characteristic_id: 2, value: 'true'},
    {service_id: 3, characteristic_id: 3, value: 'true'},
    {service_id: 4, characteristic_id: 3, value: 'true'},
]

user_traveler_characteristics_map = [
    {user_profile_id: 1, characteristic_id: 1, value: 'true'},
    {user_profile_id: 1, characteristic_id: 2, value: 'true'},
    {user_profile_id: 2, characteristic_id: 2, value: 'true'},
    {user_profile_id: 2, characteristic_id: 3, value: 'true'},
    {user_profile_id: 2, characteristic_id: 4, value: '19330511'},
    {user_profile_id: 2, characteristic_id: 5, value: '80'},
]


service_traveler_accommodations_map = [
    {service_id: 1, accommodation_id: 1, value: 'true'},
]

user_traveler_accommodations_map = [
    {user_profile_id: 2, accommodation_id: 1, value: 'true'},
]

value_relationship = [
    {id: 1, relationship: 'eq'},
    {id: 2, relationship: 'gt'},
    {id: 3, relationship: 'gte'},
    {id: 4, relationship: 'lt'},
    {id: 5, relationship: 'lte'},
    {id: 6, relationship: 'before'},
    {id: 7, relationship: 'after'},
]
#day 0 is Sunday
schedules = [
    {service_id: 1, start_time: "7:00", end_time: "19:00", day_of_week: 1},
    {service_id: 2, start_time: "0:00", end_time: "23:00", day_of_week: 0},
    {service_id: 2, start_time: "0:00", end_time: "23:00", day_of_week: 1},
    {service_id: 2, start_time: "0:00", end_time: "23:00", day_of_week: 2},
    {service_id: 2, start_time: "0:00", end_time: "23:00", day_of_week: 3},
    {service_id: 2, start_time: "0:00", end_time: "23:00", day_of_week: 4},
    {service_id: 2, start_time: "0:00", end_time: "23:00", day_of_week: 5},
    {service_id: 2, start_time: "0:00", end_time: "23:00", day_of_week: 6},
]

value_relationship.each do |relationship|
  vr = ValueRelationship.create! relationship
  vr.save
end

traveler_accommodations.each do |traveler_accommodation|
  puts "Add traveler_accommodation #{traveler_accommodation[:name]}"
  ta = TravelerAccommodation.create! traveler_accommodation
  ta.save
end

traveler_characteristics.each do |traveler_characteristic|
  puts "Add traveler_characteristic #{traveler_characteristic[:name]}"
  tc = TravelerCharacteristic.create! traveler_characteristic
  tc.save
end

providers.each do |provider|
  puts "Add/replace provider #{provider[:external_id]}"
  Provider.find_by_external_id(provider[:external_id]).destroy rescue nil
  p = Provider.create! provider
  p.save
end

service_types.each do |service_type|
  puts "Add service_type #{service_type[:name]}"
  st = ServiceType.create! service_type
  st.save
end

services.each do |service|
  puts "Add service #{service[:name]}"
  s = Service.create! service
  s.save
end

service_traveler_characteristics_map.each do |mapping|
  stcm = ServiceTravelerCharacteristicsMap.create! mapping
  stcm.save
end

user_traveler_characteristics_map.each do |mapping|
  utcm = UserTravelerCharacteristicsMap.create! mapping
  utcm.save
end

service_traveler_accommodations_map.each do |mapping|
  stam = ServiceTravelerAccommodationsMap.create! mapping
  stam.save
end

user_traveler_accommodations_map.each do |mapping|
  utam = UserTravelerAccommodationsMap.create! mapping
  utam.save
end

schedules.each do |schedule|
  s = Schedule.create! schedule
  s.save
end



