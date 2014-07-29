require File.join(Rails.root, 'db', 'common_seeds.rb')

require File.join(Rails.root, 'db', Oneclick::Application.config.brand.to_s + '/' + Oneclick::Application.config.brand.to_s + '_seeds.rb')

KioskLocation.create!([{
  name: 'machine1',
  address_type: 6,
  addr: '828 Mitchell Street Southwest, Atlanta, GA 30314',
  lat: 33.7532,
  lon:  -84.4146
},
{
  name: 'machine2',
  address_type: 6,
  addr: '2891 Lakewood Avenue Southwest, Atlanta, GA 30315',
  lat: 33.6973,
  lon: -84.4113
}])
