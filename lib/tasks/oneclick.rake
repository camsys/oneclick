#encoding: utf-8
namespace :oneclick do
  task :seed_data => :environment do
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
    ]
    users.each do |user|
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
  end
end
