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

# load the roles
roles.each do |role|
  r = Role.new(role)
  r.save!
end

# load the reports
reports.each do |rep|
  r = Report.new(rep)
  r.save!
end

#Create Admin User
User.find_by_email(admin[:email]).destroy rescue nil
admin = {first_name: 'sys', last_name: 'admin', email: 'email@camsys.com'}
u = User.create! admin.merge({password: 'welcome1'})
up = UserProfile.new
up.user = u
up.save!
u.add_role 'admin'
u.save!

