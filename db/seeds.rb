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
    {id:1, name: 'Disabled', note: 'Is the traveler disabled?', datatype: 'bool'},
    {id:2, name: 'No Means of Transportation', note: 'The traveler has no alternative means of transportation.', datatype: 'bool'},
    {id:3, name: 'Medicaid/NEMT Eligible', note: 'Is the traveler Medicaid or NEMT Eligible?', datatype: 'bool'},
    {id:4, name: 'ADA Paratransit Eligible', note: 'Is the traveler ADA Paratransit eligible?', datatype: 'bool'},
    {id:5, name: 'Veteran', note: 'Is the traveler a veteran?', datatype: 'bool'},
    {id:6, name: 'Medicare Eligible', note: 'Is the traveler Medicare Eligible?', datatype: 'bool'},
    {id:7, name: 'Low income', note: 'Low income traveler.', datatype: 'bool'},
    {id:8, name: 'Date of Birth', note: '', datatype: 'date'},
    {id:9, name: 'Age', note: '', datatype: 'integer'},
]

traveler_accommodations = [
    {id:1, name: 'Wheelchair Accessible', note: 'The passenger requires a wheelchair accessible service.', datatype: 'bool'},
    {id:2, name: 'Door-to-door', note: 'The passenger requires door-to-door service.', datatype: 'bool'},
    {id:3, name: 'Curb-to-curb', note: 'The passenger requires curb-to-curb service.', datatype: 'bool'},
]

providers = [
    {id: 1, name: 'Metro Medical Transportation', contact: 'name here', external_id: "esp#2"},
    {id: 2, name: 'Clayton County Transportation Services', contact: 'John Clayton', external_id: "esp#9"},
    {id: 3, name: 'Cobb Transportation Services', contact: 'Susan Cobb', external_id: "esp#13"},
    {id: 4, name: 'Douglas Trans. Services', contact: 'Doug Douglas', external_id: "esp#22"},
    {id: 5, name: 'ATL Limo', contact: 'Mr. Limo', external_id: "esp#45"},

]

service_types = [
    {id: 1, name: 'Paratransit', note: 'This is a general purpose paratransit service.'},
    {id: 2, name: 'Non-Emergency Medical Service', note: 'This is a paratransit service only to be used for medical trips.'},
    {id: 3, name: 'Livery', note: 'Car service for hire.'},
]

services = [
    {id: 1, name: 'Metro DRT', provider_id: 1, service_type_id: 1, advanced_notice_minutes: 24*60},
    {id: 2, name: 'Clayton NEMT', provider_id: 2, service_type_id: 2, advanced_notice_minutes: 14*24*60},
    {id: 3, name: 'Cobb DRT', provider_id: 3, service_type_id: 1, advanced_notice_minutes: 5*24*60},
    {id: 4, name: 'Douglas DRT', provider_id: 4, service_type_id: 1, advanced_notice_minutes: 2*24*60},
    {id: 5, name: 'Atlanta Town Car Service', provider_id: 5, service_type_id: 3, advanced_notice_minutes: 60},

]

service_traveler_characteristics_map = [
    {service_id: 2, characteristic_id: 9, value: '60', value_relationship_id: 4},
    {service_id: 3, characteristic_id: 9, value: '60', value_relationship_id: 4},
    {service_id: 4, characteristic_id: 9, value: '60', value_relationship_id: 4},
    {service_id: 4, characteristic_id: 1, value: 'true'},
]

user_traveler_characteristics_map = [
    {user_profile_id: 2, characteristic_id: 1, value: 'true'},
    {user_profile_id: 2, characteristic_id: 3, value: 'true'},
    {user_profile_id: 2, characteristic_id: 4, value: '23/11/1922'},
]


service_traveler_accommodations_map = [
    {service_id: 2, accommodation_id: 1, value: 'true'},
    {service_id: 3, accommodation_id: 1, value: 'true'},
    {service_id: 3, accommodation_id: 2, value: 'true'},
    {service_id: 4, accommodation_id: 1, value: 'true'},
]

user_traveler_accommodations_map = [
    {user_profile_id: 2, accommodation_id: 1, value: 'false'},
]

#day 0 is Sunday
schedules = [
    {service_id: 1, start_time: "8:30", end_time: "16:30", day_of_week: 1},
    {service_id: 1, start_time: "8:30", end_time: "16:30", day_of_week: 2},
    {service_id: 1, start_time: "8:30", end_time: "16:30", day_of_week: 3},
    {service_id: 1, start_time: "8:30", end_time: "16:30", day_of_week: 4},
    {service_id: 1, start_time: "8:30", end_time: "16:30", day_of_week: 5},
    {service_id: 2, start_time: "8:00", end_time: "14:00", day_of_week: 1},
    {service_id: 2, start_time: "8:00", end_time: "14:00", day_of_week: 2},
    {service_id: 2, start_time: "8:00", end_time: "14:00", day_of_week: 3},
    {service_id: 2, start_time: "8:00", end_time: "14:00", day_of_week: 4},
    {service_id: 2, start_time: "8:00", end_time: "14:00", day_of_week: 5},
    {service_id: 3, start_time: "8:00", end_time: "16:00", day_of_week: 1},
    {service_id: 3, start_time: "8:00", end_time: "16:00", day_of_week: 3},
    {service_id: 3, start_time: "8:00", end_time: "16:00", day_of_week: 5},
    {service_id: 4, start_time: "00:00", end_time: "23:59", day_of_week: 3},
    {service_id: 5, start_time: "00:00", end_time: "23:59", day_of_week: 0},
    {service_id: 5, start_time: "00:00", end_time: "23:59", day_of_week: 1},
    {service_id: 5, start_time: "00:00", end_time: "23:59", day_of_week: 2},
    {service_id: 5, start_time: "00:00", end_time: "23:59", day_of_week: 3},
    {service_id: 5, start_time: "00:00", end_time: "23:59", day_of_week: 4},
    {service_id: 5, start_time: "00:00", end_time: "23:59", day_of_week: 5},
    {service_id: 5, start_time: "00:00", end_time: "23:59", day_of_week: 6},

]

trip_purposes = [
    {id: 1, name: 'Work', note: 'Work-related trip.', active: 1},
    {id: 2, name: 'Training/Employment', note: 'Employment or training trip.', active: 1},
    {id: 3, name: 'Medical', note: 'General medical trip.', active: 1},
    {id: 4, name: 'Dialysis', note: 'Dialysis appointment.', active: 1},
    {id: 5, name: 'Cancer Treatment', note: 'Trip to receive cancer treatment.', active: 1},
    {id: 6, name: 'Personal Errand', note: 'Personal errand/shopping trip.', active: 1},
    {id: 7, name: 'General Purpose', note: 'General purpose/unspecified purpose.', active: 1}
]

service_trip_purpose_map = [
    {service_id: 1, trip_purpose_id: 3, value: 'true'},
    {service_id: 1, trip_purpose_id: 4, value: 'true'},
    {service_id: 1, trip_purpose_id: 5, value: 'true'},
    {service_id: 2, trip_purpose_id: 1, value: 'true'},
    {service_id: 2, trip_purpose_id: 2, value: 'true'},
    {service_id: 2, trip_purpose_id: 3, value: 'true'},
    {service_id: 2, trip_purpose_id: 4, value: 'true'},
    {service_id: 2, trip_purpose_id: 5, value: 'true'},
    {service_id: 2, trip_purpose_id: 6, value: 'true'},
    {service_id: 2, trip_purpose_id: 7, value: 'true'},
    {service_id: 3, trip_purpose_id: 3, value: 'true'},
    {service_id: 3, trip_purpose_id: 4, value: 'true'},
    {service_id: 3, trip_purpose_id: 5, value: 'true'},
    {service_id: 4, trip_purpose_id: 3, value: 'true'},
    {service_id: 4, trip_purpose_id: 4, value: 'true'},
    {service_id: 4, trip_purpose_id: 5, value: 'true'},
    {service_id: 5, trip_purpose_id: 1, value: 'true'},
    {service_id: 5, trip_purpose_id: 2, value: 'true'},
    {service_id: 5, trip_purpose_id: 3, value: 'true'},
    {service_id: 5, trip_purpose_id: 4, value: 'true'},
    {service_id: 5, trip_purpose_id: 5, value: 'true'},
    {service_id: 5, trip_purpose_id: 6, value: 'true'},
    {service_id: 5, trip_purpose_id: 7, value: 'true'},
]

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

trip_purposes.each do |trip_purpose|
  t = TripPurpose.create! trip_purpose
  t.save
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

service_trip_purpose_map.each do |mapping|
  stpm = ServiceTripPurposeMap.create! mapping
  stpm.save
end

user_traveler_accommodations_map.each do |mapping|
  utam = UserTravelerAccommodationsMap.create! mapping
  utam.save
end

schedules.each do |schedule|
  s = Schedule.create! schedule
  s.save
end




