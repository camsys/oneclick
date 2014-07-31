require File.join(Rails.root, 'db', 'common_seeds.rb')

require File.join(Rails.root, 'db', Oneclick::Application.config.brand.to_s + '/' + Oneclick::Application.config.brand.to_s + '_seeds.rb')


case Oneclick::Application.config.brand
when 'pa'
  KioskLocation.create!([{
    name: 'machine1',
    address_type: 6,
    addr: '1230 Roosevelt Ave, York, PA 17404',
    lat: 39.975886,
    lon: -76.756512
  }])
else
  KioskLocation.create!([{
    name: 'machine1',
    address_type: 6,
    addr: '828 Mitchell Street Southwest, Atlanta, GA 30314',
    lat: 33.7532,
    lon: -84.4146
  },
  {
    name: 'machine2',
    address_type: 6,
    addr: '2891 Lakewood Avenue Southwest, Atlanta, GA 30315',
    lat: 33.6973,
    lon: -84.4113
  }])
end
