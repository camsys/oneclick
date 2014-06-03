include SeedsHelpers

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

#Create reports and internationalize their names
[
    {name: 'Trips Created', description: 'Displays a chart showing the number of trips created each day.', view_name: 'generic_report', class_name: 'TripsCreatedByDayReport', active: 1},
    {name: 'Trips Scheduled', description: 'Displays a chart showing the number of trips scheduled for each day.', view_name: 'generic_report', class_name: 'TripsScheduledByDayReport', active: 1},
    {name: 'Failed Trips', description: 'Displays a report describing the trips that failed.', view_name: 'trips_report', class_name: 'InvalidTripsReport', active: 1},
    {name: 'Rejected Trips', description: 'Displays a report showing trips that were rejected by a user.', view_name: 'trips_report', class_name: 'RejectedTripsReport', active: 1}
].each do |rep|
  Report.create!(rep)
  Translation.find_or_create_by!(key: rep[:class_name], locale: :en, value: rep[:class_name])
  Translation.find_or_create_by!(key: rep[:class_name], locale: :es, value: "[es]#{rep[:class_name]}[/es]")
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
  { klass: Mode, active: 1, name: 'Transit', code: 'mode_transit', otp_mode: "TRANSIT,WALK"}
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
 { klass: Mode, active: 1, name: 'Paratransit', code: 'mode_paratransit', elig_dependent: true},
 { klass: Mode, active: 1, name: 'Taxi', code: 'mode_taxi'},
 { klass: Mode, active: 0, name: 'Rideshare', code: 'mode_rideshare'},
 { klass: Mode, active: 0, name: 'Bike', code: 'mode_bicycle', otp_mode: "BICYCLE"},
 { klass: Mode, active: 0, name: 'Bikeshare', code: 'mode_bikeshare'},
 { klass: Mode, active: 0, name: 'Drive', code: 'mode_car', otp_mode: "CAR"},
 { klass: Mode, active: 0, name: 'Walk', code: 'mode_walk', otp_mode: "WALK"},
 { klass: Mode, active: 1, name: 'Bus', code: 'mode_bus', otp_mode: "BUSISH,WALK",
   parent_id: transit_mode.id },
 { klass: Mode, active: 1, name: 'Rail', code: 'mode_rail', otp_mode: "TRAINISH,WALK",
   parent_id: transit_mode.id },
 { klass: Mode, active: 0, name: 'Bike and Ride', code: 'mode_bike_park_transit',
   otp_mode: "BICYCLE_PARK,WALK,TRANSIT", parent_id: transit_mode.id },
 { klass: Mode, active: 0, name: 'Kiss and Ride', code: 'mode_car_transit',
   otp_mode: "CAR,WALK,TRANSIT", parent_id: transit_mode.id },
 { klass: Mode, active: 0, name: 'Park and Ride', code: 'mode_park_transit',
   otp_mode: "CAR_PARK,WALK,TRANSIT", parent_id: transit_mode.id },
 { klass: Mode, active: 0, name: 'Bicycle & Transit', code: 'mode_bike_transit',
   otp_mode: "TRANSIT,BICYCLE", parent_id: transit_mode.id }
 
].each do |record|
  structured_hash = structure_records_from_flat_hash record
  build_internationalized_records structured_hash
end
