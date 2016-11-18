include SeedsHelpers
include Rake

Rake::Task["translation_engine:implement_new_database_schema"].invoke

### Non Internationlized Records ###

# TODO This is actually not necessary,  because of the way rolify works
# load the roles
%w{
  system_administrator
  agency_administrator
  agent
  provider_staff
  registered_traveler
  anonymous_traveler
}.each do |role|
  Role.create!(name: role.to_sym)
end

# Create Admin User
User.find_by_email(admin[:email]).destroy rescue nil
u = User.find_or_create_by!(email: 'email@camsys.com') do |u|
  u.first_name = 'sys'
  u.last_name = 'admin'
  u.password = u.password_confirmation ='welcome1'

end
up = UserProfile.find_or_create_by! user: u
u.add_role :system_administrator

### Internationalized Records ###

# Transit has to be handled separate to support submodes.
transit_hash =
  { klass: Mode, active: 1, name: 'Transit', code: 'mode_transit', otp_mode: "TRANSIT,WALK",
    logo_url: 'modes/transit.png', visible: true,}
transit_mode = build_internationalized_records(structure_records_from_flat_hash(transit_hash))

[
  # load the trip statuses
  { klass: TripStatus, active: 1, name: 'New', code: 'trip_status_new'},
  { klass: TripStatus, active: 1, name: 'In Progress',code: 'trip_status_in_progress'},
  { klass: TripStatus, active: 1, name: 'Completed',code: 'trip_status_completed'},
  { klass: TripStatus, active: 1, name: 'Errored',code: 'trip_status_errored'},

  #Create relationship statuses
  { klass: RelationshipStatus, name: 'Requested', code: 'relationship_status_requested'},
  { klass: RelationshipStatus, name: 'Pending', code: 'relationship_status_pending'},
  { klass: RelationshipStatus, name: 'Confirmed', code: 'relationship_status_confirmed'},
  { klass: RelationshipStatus, name: 'Denied', code: 'relationship_status_denied'},
  { klass: RelationshipStatus, name: 'Revoked', code: 'relationship_status_revoked'},
  { klass: RelationshipStatus, name: 'Hidden', code: 'relationship_status_hidden'},

  # Modes
  {
    klass: Mode,
    active: 1,
    name: 'Paratransit',
    code: 'mode_paratransit',
    elig_dependent: true,
    logo_url: 'https://s3.amazonaws.com/oneclick-rtd/modes/paratransit.png',
    visible: true
  },
  {
    klass: Mode,
    active: 1,
    name: 'Taxi',
    code: 'mode_taxi',
    logo_url: 'https://s3.amazonaws.com/oneclick-rtd/modes/taxi.png',
    visible: true
  },
  {
    klass: Mode,
    active: 0,
    name: 'Rideshare',
    code: 'mode_rideshare',
    logo_url: 'https://s3.amazonaws.com/oneclick-rtd/modes/rideshare.png',
  },
  {
    klass: Mode,
    active: 0,
    name: 'Bike',
    code: 'mode_bicycle',
    otp_mode: "BICYCLE",
    logo_url: 'https://s3.amazonaws.com/oneclick-rtds/modes/bicycle.png',
  },
  {
    klass: Mode,
    active: 0,
    name: 'Bikeshare',
    code: 'mode_bikeshare',
    logo_url: 'https://s3.amazonaws.com/oneclick-rtd/modes/bicycle.png',
  },
  {
    klass: Mode,
    active: 0,
    name: 'Drive',
    code: 'mode_car',
    otp_mode: "CAR",
    logo_url: 'https://s3.amazonaws.com/oneclick-rtd/modes/auto.png',
  },
  {
    klass: Mode,
    active: 0,
    name: 'Walk',
    code: 'mode_walk',
    otp_mode: "WALK",
    logo_url: 'https://s3.amazonaws.com/oneclick-rtd/modes/walk.png',
  },
  {
    klass: Mode,
    active: 1,
    name: 'Bus', code: 'mode_bus',
    otp_mode: "BUSISH,WALK",
    parent_id: transit_mode.id,
    logo_url: 'https://s3.amazonaws.com/oneclick-rtd/modes/transit.png',
    visible: true
  },
  {
    klass: Mode,
    active: 1,
    name: 'Rail',
    code: 'mode_rail',
    otp_mode: "TRAINISH,WALK",
    parent_id: transit_mode.id,
    logo_url: 'https://s3.amazonaws.com/oneclick-rtd/modes/rail.png',
    visible: true
  },
  {
    klass: Mode,
    active: 0,
    name: 'Bike and Ride',
    code: 'mode_bike_park_transit',
    otp_mode: "BICYCLE_PARK,WALK,TRANSIT",
    parent_id: transit_mode.id,
    logo_url: 'https://s3.amazonaws.com/oneclick-rtd/modes/bicycle.png',
  },
  {
    klass: Mode,
    active: 0,
    name: 'Kiss and Ride',
    code: 'mode_car_transit',
    otp_mode: "CAR,WALK,TRANSIT",
    parent_id: transit_mode.id,
    logo_url: 'https://s3.amazonaws.com/oneclick-rtd/modes/transit.png',
  },
  {
    klass: Mode,
    active: 0,
    name: 'Park and Ride',
    code: 'mode_park_transit',
    otp_mode: "CAR_PARK,WALK,TRANSIT",
    parent_id: transit_mode.id,
    logo_url: 'https://s3.amazonaws.com/oneclick-rtd/modes/transit.png',
  },
  {
    klass: Mode,
    active: 0,
    name: 'Bicycle & Transit',
    code: 'mode_bicycle_transit',
    otp_mode: "TRANSIT,BICYCLE",
    parent_id: transit_mode.id,
    logo_url: 'https://s3.amazonaws.com/oneclick-rtd/modes/bicycle.png',
  },
  {
    klass: Mode,
    active: 0,
    name: 'mode_ride_hailing_name',
    code: 'mode_ride_hailing',
    logo_url: 'https://s3.amazonaws.com/oneclick-rtd/modes/auto.png'
  },
  {
    klass: Mode,
    active: 1,
    visible: 0,
    name: 'mode_ferry_name',
    code: 'mode_ferry',
    otp_mode: "FERRY",
    logo_url: 'https://s3.amazonaws.com/oneclick-rtd/modes/ferry.png'
  },
  {
    klass: Mode,
    active: 1,
    visible: 0,
    name: 'mode_cable_car_name',
    code: 'mode_cable_car',
    otp_mode: "CABLE_CAR",
    logo_url: 'https://s3.amazonaws.com/oneclick-rtd/modes/cable_car.png'
  },
  {
    klass: Mode,
    active: 1,
    visible: 0,
    name: 'mode_gondola_name',
    code: 'mode_gondola',
    otp_mode: "GONDOLA",
    logo_url: 'https://s3.amazonaws.com/oneclick-rtd/modes/gondola.png'
  },
  {
    klass: Mode,
    active: 1,
    visible: 0,
    name: 'mode_funicular_name',
    code: 'mode_funicular',
    otp_mode: "FUNICULAR",
    logo_url: 'https://s3.amazonaws.com/oneclick-rtd/modes/funicular.png'
  },
  {
    klass: Mode,
    active: 1,
    visible: 0,
    name: 'mode_subway_name',
    code: 'mode_subway',
    otp_mode: "SUBWAY",
    logo_url: 'https://s3.amazonaws.com/oneclick-rtd/modes/subway.png'
  },
  {
    klass: Mode,
    active: 1,
    visible: 0,
    name: 'mode_tram_name',
    code: 'mode_tram',
    otp_mode: "TRAM",
    logo_url: 'https://s3.amazonaws.com/oneclick-rtd/modes/tram.png'
  },

 { klass: DateOption, name: 'All', code: 'date_option_all',
   start_date: 'beginning of time', end_date: 'end of time',
 },
 { klass: DateOption, name: 'Past', code: 'date_option_past',
   start_date: 'beginning of time', end_date: 'now',
 },
 { klass: DateOption, name: 'Future', code: 'date_option_future',
   start_date: 'now', end_date: 'end of time',
 },
 { klass: DateOption, name: 'Last 7 Days', code: 'date_option_last_7_days',
   start_date: '7 days ago', end_date: 'now',
 },
 { klass: DateOption, name: 'Next 7 Days', code: 'date_option_next_7_days',
   start_date: 'now', end_date: '7 days from now',
 },
 { klass: DateOption, name: 'Last 30 Days', code: 'date_option_last_30_days',
   start_date: '30 days ago', end_date: 'now',
 },
 { klass: DateOption, name: 'Next 30 Days', code: 'date_option_next_30_days',
   start_date: 'now', end_date: '30 days from now',
 },
 { klass: DateOption, name: 'Last Month', code: 'date_option_last_month',
   start_date: 'last month', end_date: 'last month',
 },
 { klass: DateOption, name: 'Next Month', code: 'date_option_next_month',
   start_date: 'next month', end_date: 'next month',
 },
 { klass: DateOption, name: 'Custom...', code: 'date_option_custom',
 },

].each do |record|
  structured_hash = structure_records_from_flat_hash record
  build_internationalized_records structured_hash
end

WalkingSpeed.where(code: 'slow', name: 'Slow', value: 2).first_or_create!
WalkingSpeed.where(code: 'average', name: 'Average', value: 3, is_default: true).first_or_create!
WalkingSpeed.where(code: 'fast', name: 'Fast', value: 4).first_or_create!

WalkingMaximumDistance.where(value: 0.25).first_or_create!
WalkingMaximumDistance.where(value: 0.5).first_or_create!
WalkingMaximumDistance.where(value: 0.75).first_or_create!
WalkingMaximumDistance.where(value: 1).first_or_create!
WalkingMaximumDistance.where(value: 1.5).first_or_create!
WalkingMaximumDistance.where(value: 2, is_default: true).first_or_create!
WalkingMaximumDistance.where(value: 3).first_or_create!
WalkingMaximumDistance.where(value: 4).first_or_create!

#Traveler characteristics
[{klass:Characteristic, characteristic_type: 'personal_factor', code: 'disabled', name: 'Disabled', note: 'Do you have a permanent or temporary disability?', datatype: 'bool'},
#{klass:Characteristic, characteristic_type: 'personal_factor', code: 'no_tranQs', name: 'No Means of Transportation', note: 'Do you own or have access to a personal vehicle?', datatype: 'bool', desc: },
#{klass:Characteristic, characteristic_type: 'program', code: 'nemt_eligible', name: 'Medicaid', note: 'Are you eligible for Medicaid?', datatype: 'bool', desc:},
    {klass:Characteristic, characteristic_type: 'program', code: 'ada_eligible', name: 'ADA Paratransit', note: 'Are you eligible for ADA paratransit?', datatype: 'bool'},
    {klass:Characteristic, characteristic_type: 'program', code: 'matp', name: 'Medical Assistance Transportation Program', note: 'Do you have a Medical Assistance Access Card?', datatype: 'bool'},
    {klass:Characteristic, characteristic_type: 'personal_factor', code: 'veteran', name: 'Veteran', note: 'Are you a military veteran?', datatype: 'bool'},
#{klass:Characteristic, characteristic_type: 'personal_factor', code: 'low_income', name: 'Low income', note: "Are you low income?", datatype: 'disabled',desc: },
    {klass:Characteristic, characteristic_type: 'personal_factor', code: 'date_of_birth', name: 'Date of Birth', note: "What is your birth year?", datatype: 'date'},
    { klass: Characteristic, characteristic_type: 'personal_factor', code: 'age', name: 'Age is', note: "What is your birth year?", datatype: 'integer',
    desc: 'You must be 65 or older to use this service. Please confirm your birth year.'},
    {klass:Characteristic, characteristic_type: 'personal_factor', code: 'walk_distance', name: 'Walk distance', note: 'Are you able to comfortably walk for 5, 10, 15, 20, 25, 30 minutes?', datatype: 'disabled'},

#Traveler accommodations
    {klass:Accommodation, code: 'folding_wheelchair_accessible', name: 'Folding wheelchair accessible.', note: 'Do you need a vehicle that has space for a folding wheelchair?', datatype: 'bool'},
    {klass:Accommodation, code: 'motorized_wheelchair_accessible', name: 'Motorized wheelchair accessible.', note: 'Do you need a vehicle than has space for a motorized wheelchair?', datatype: 'bool'},
#{klass:Accommodation, code: 'door_to_door', name: 'Door-to-door', note: 'Do you need assistance getting to your front door?', datatype: 'bool'},
    {klass:Accommodation, code: 'curb_to_curb', name: 'Curb-to-curb', note: 'Do you need delivery to the curb in front of your home?', datatype: 'bool'},
#{klass:Accommodation, code: 'driver_assistance_available', name: 'Driver assistance available.', note: 'Do you need personal assistance from the driver?', datatype: 'bool'},
#Service types
    {klass:ServiceType, code: 'paratransit', name: 'Paratransit', note: 'This is a general purpose paratransit service.'},
    {klass:ServiceType, code: 'volunteer', name: 'Volunteer', note: 'This is a volunteer service'},
    {klass:ServiceType, code: 'nemt', name: 'Non-Emergency Medical Service', note: 'This is a paratransit service only to be used for medical trips.'},
    {klass: ServiceType, code: 'transit', name: 'Fixed-route Transit', note: 'This is a transit service.'},
    {klass: ServiceType, code: 'taxi', name: 'Taxi', note: 'Taxi services.'},
].each do |record|
  structured_hash = structure_records_from_flat_hash record
  build_internationalized_records structured_hash
end

#trip_purposes
# {klass:TripPurpose, code: 'medical', name: 'Medical', note: 'General medical trip.', active: 1, sort_order: 2},
# {klass:TripPurpose, code: 'cancer', name: 'Cancer Treatment', note: 'Trip to receive cancer treatment.', active: 1, sort_order: 2},
# {klass:TripPurpose, code: 'general', name: 'General Purpose', note: 'General purpose/unspecified purpose.', active: 1, sort_order: 1},
#  {klass:TripPurpose, code: 'grocery', name: 'Grocery Trip', note: 'Grocery shopping trip.', active: 1, sort_order: 2}
#  # {klass:TripPurpose, code: 'vamc', name: 'Visit Lebanon VA Medical Center', note: 'Visit Lebanon VA Medical Center', active: 1, sort_order: 2}

['Other',
 'Grocery',
 'Medical',
 'Work'].each do |name|
  record = {klass:TripPurpose, code: name.downcase.gsub(%r{[ /]}, '_'), name: name, note: name, active: 1, sort_order: 2}
  record[:sort_order] = 1 if record[:code]=='general_purpose'
  record[:sort_order] = 3 if record[:code]=='other'
  structured_hash = structure_records_from_flat_hash record
  build_internationalized_records structured_hash
end

# update linked characteristics
age = Characteristic.unscoped.find_by(code: 'age')
dob = Characteristic.unscoped.find_by(code: 'date_of_birth')

dob.update_attributes!(for_service: false, linked_characteristic: age,
    link_handler: 'AgeCharacteristicHandler') rescue puts "dob.update_attributes! failed"

age.update_attributes!(for_traveler: false, linked_characteristic: dob,
    link_handler: 'AgeCharacteristicHandler') rescue Rails.logger.warn "age.update_attributes failed!"

#Run additional Rake Tasks
Oneclick::Application.load_tasks
Rake::Task["oneclick:load_locales"].invoke
