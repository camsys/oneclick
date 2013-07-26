#encoding: utf-8
namespace :oneclick do
  task :seed_data => :environment do
    User.find_by_email('dhaskin@camsys.com').destroy rescue nil
    u = User.create! first_name: 'Denis', last_name: 'Haskin', email: 'dhaskin@camsys.com', password: 'welcome1'
    [ {name: 'My house', nongeocoded_address: '730 Peachtree St NE, Atlanta, GA 30308'},
      {name: 'La oficina de mi médico', nongeocoded_address: '1670 Clairmont Rd, Decatur, GA'}
      ].each do |place|
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
