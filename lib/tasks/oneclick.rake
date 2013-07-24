#encoding: utf-8
namespace :oneclick do
  task :seed_data => :environment do
    User.find_by_email('dhaskin@camsys.com').destroy
    u = User.create! first_name: 'Denis', last_name: 'Haskin', email: 'dhaskin@camsys.com', password: 'welcome1'
    [{name: 'My house',
      address: '730 Peachtree St NE',
      city: 'Atlanta',
      state: 'GA',
      zip: '30308'},
      {name: 'La oficina de mi médico',
        address: '1670 Clairmont Rd',
        city: 'Decatur',
        state: 'GA'}
        ].each do |place|
          u.places << Place.new(place)
          u.save!
        end
      end
    end
