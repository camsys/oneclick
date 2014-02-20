case Oneclick::Application.config.brand
when 'pa'
  require File.join(Rails.root, 'db', 'pa_seeds.rb')
when 'arc'
  require File.join(Rails.root, 'db', 'atl_seeds.rb')
when 'broward'
  require File.join(Rails.root, 'db', 'broward_seeds.rb')
else
  raise "Brand #{Oneclick::Application.config.brand} not handled"
end

KioskLocation.create!([{
  name: 'machine1',
  poi_id: 8768,
  address_type: 6,
  addr: '828 Mitchell Street Southwest, Atlanta, GA 30314',
  lat: 33.7532,
  lon:  -84.4146
},
{
  name: 'machine2',
  poi_id: 8813,
  address_type: 6,
  addr: '2891 Lakewood Avenue Southwest, Atlanta, GA 30315',
  lat: 33.6973,
  lon: -84.4113
}])
