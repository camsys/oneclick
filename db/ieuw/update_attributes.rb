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

include SeedsHelpers

####Add Missing Attributes

#Traveler characteristics
[{klass:Characteristic, characteristic_type: 'personal_factor', code: 'physically_disabled', name: 'Physically Disabled', note: 'Do you have a physical disability?', datatype: 'bool'},
{klass:Characteristic, characteristic_type: 'personal_factor', code: 'use_other_trans', name: 'Can use other transportation', note: 'Are you able to drive or use public transit?', datatype: 'bool'},

#Traveler accommodations 
{klass:Accommodation, code: 'door_to_door', name: 'Door-to-door', note: 'Do you need assistance getting to your front door?', datatype: 'bool'},
{klass:Accommodation, code: 'driver_assistance', name: 'Driver assistance provided', note: 'Do you require assistance from the driver to enter the vehicle?', datatype: 'bool'},
{klass:Accommodation, code: 'wheelchair_lift_equipped', name: 'Wheelchair lift equipped', note: 'Do you require a vehicle equipped with a wheelchair lift?', datatype: 'bool'},
].each do |record|
  structured_hash = structure_records_from_flat_hash record
  build_internationalized_records structured_hash
end

#Trip Purposes
names = ['General Medical', 'Visit Senior Center']
names.each do |name|
  record = {klass:TripPurpose, code: name.downcase.gsub(%r{[ /]}, '_'), name: name, note: name, active: 1, sort_order: 2}
  record[:sort_order] = 1 if record[:code]=='general_purpose'
  record[:sort_order] = 3 if record[:code]=='other'
  structured_hash = structure_records_from_flat_hash record
  build_internationalized_records structured_hash
end

#####Remove Unused Attributes

#Eligbility Characteristics
codes = ['physically_disabled',
         'date_of_birth',
         'age',
         'veteran',
         'ada_eligible',
         'use_other_trans'
         ]

Characteristic.all.each do |c|
  unless c.code.in? codes
    c.delete
  end
end

#Trip Purposes
names = ['Cancer Treatment',
 'Other',
 'Grocery',
 'General Medical',
 'Visit Senior Center']

names.map!{ |name| name.downcase.gsub(%r{[ /]}, '_')}

TripPurpose.all.each do |tp|
  unless tp.code.in? names
    tp.delete
  end
end




