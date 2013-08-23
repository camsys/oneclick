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
places = [ {name: 'My house', nongeocoded_address: '730 Peachtree St NE, Atlanta, GA 30308'},
  {name: 'Atlanta VA Medical Center', nongeocoded_address: '1670 Clairmont Rd, Decatur, GA'},
  {name: 'Formación Para el Trabajo', nongeocoded_address: '239 West Lake Avenue NW, Atlanta, GA 30314'},
  {name: 'Atlanta Mission',  nongeocoded_address: '239 West Lake Avenue NW, Atlanta, GA 30314'}
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
reports = [
  {name: 'Trips By Day Report', description: 'Displays a chart showing the number of trips generated each day.', view_name: 'generic_report', class_name: 'TripsPerDayReport', active: 1}, 
  {name: 'Failed Trips Report', description: 'Displays a report describing the trips that failed.', view_name: 'trips_report', class_name: 'InvalidTripsReport', active: 1}, 
  {name: 'Rejected Report', description: 'Displays a report showing trips that were rejected by a user.', view_name: 'trips_report', class_name: 'RejectedTripsReport', active: 1} 
]
users.each do |user|
  puts "Add/replace user #{user[:email]}"
  User.find_by_email(user[:email]).destroy rescue nil
  u = User.create! user.merge({password: 'welcome1'})
  places.each do |place|
    p = UserPlace.new(place)
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
end
# load the roles
roles.each do |role| 
  r = Role.new
  r.name = role[:name]
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

