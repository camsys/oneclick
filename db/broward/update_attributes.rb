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
[{klass:Characteristic, characteristic_type: 'personal_factor', code: 'developmentally_disabled', name: 'Developmentally Disabled', note: 'Do you have a developmental disability?', datatype: 'bool'},
{klass:Characteristic, characteristic_type: 'personal_factor', code: 'homeless', name: 'Homeless/Facing Eviciton', note: 'Are you homeless or facing eviction?', datatype: 'bool'}].each do |record|
  structured_hash = structure_records_from_flat_hash record
  build_internationalized_records structured_hash
end



#Trip Purposes
['Travel to Family Member',
'Travel to Meal',
'Leisure',
'Visit Social Service Agency'].each do |name|

  record = {klass:TripPurpose, code: name.downcase.gsub(%r{[ /]}, '_'), name: name, note: name, active: 1, sort_order: 2}
  record[:sort_order] = 1 if record[:code]=='general_purpose'
  record[:sort_order] = 3 if record[:code]=='other'
  structured_hash = structure_records_from_flat_hash record
  build_internationalized_records structured_hash
end

#County Coverage Areas
['Broward', 'Palm Beach', 'Miami-Dade'].each do |c|
  GeoCoverage.find_or_create_by(value: c, coverage_type: 'county_name')
end

#####Remove Unused Attributes

#Eligbility Characteristics
codes = ['developmentally_disabled',
         'disabled',
         'ada_eligible',
         'no_trans',
         'homeless',
         'date_of_birth',
         'age',
         ]

Characteristic.all.each do |c|
  unless c.code.in? codes
    c.delete
  end
end

#Trip Purposes
codes = ['cancer',
 'general',
 'medical',
 'senior',
 'grocery',
 'leisure',
 'visit_social_service_agency',
 'travel_to_family_member',
 'travel_to_meal']


TripPurpose.all.each do |tp|
  unless tp.code.in? codes
    tp.delete
  end
end




