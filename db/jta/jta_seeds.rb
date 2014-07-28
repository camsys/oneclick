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

#Traveler characteristics
[{klass:Characteristic, characteristic_type: 'personal_factor', code: 'disabled', name: 'Disabled', note: 'Do you have a permanent or temporary disability?', datatype: 'bool'},
#{klass:Characteristic, characteristic_type: 'personal_factor', code: 'no_tranQs', name: 'No Means of Transportation', note: 'Do you own or have access to a personal vehicle?', datatype: 'bool', desc: },
#{klass:Characteristic, characteristic_type: 'program', code: 'nemt_eligible', name: 'Medicaid', note: 'Are you eligible for Medicaid?', datatype: 'bool', desc:},
{klass:Characteristic, characteristic_type: 'program', code: 'ada_eligible', name: 'ADA Paratransit', note: 'Are you eligible for ADA paratransit?', datatype: 'bool'},
{klass:Characteristic, characteristic_type: 'program', code: 'matp', name: 'Medical Assistance Transportation Program', note: 'Do you have a Medical Assistance Access Card?', datatype: 'bool'},
{klass:Characteristic, characteristic_type: 'personal_factor', code: 'veteran', name: 'Veteran', note: 'Are you a military veteran?', datatype: 'bool'},
#{klass:Characteristic, characteristic_type: 'personal_factor', code: 'low_income', name: 'Low income', note: "Are you low income?", datatype: 'disabled',desc: },
{klass:Characteristic, characteristic_type: 'personal_factor', code: 'date_of_birth', name: 'Date of Birth', note: "What is your birth year?", datatype: 'date'},
 { klass: Characteristic, characteristic_type: 'personal_factor', code: 'age', name: 'Age is', note: "What is your birth year?", datatype: 'integer',
    desc: 'You must be 65 or older to use this service. Please confirm your birth year.'},
{klass:Characteristic, characteristic_type: 'personal_factor', code: 'walk_distance', name: 'Walk distance', note: 'Are you able to comfortably walk for 5, 10, 15, 20, 25, 30 minutes?', datatype: 'disabled'},

#Traveler accommodations 
{klass:Accommodation, code: 'folding_wheelchair_accessible', name: 'Folding wheelchair accessible.', note: 'Do you need a vehicle that has space for a folding wheelchair?', datatype: 'bool'}, 
{klass:Accommodation, code: 'motorized_wheelchair_accessible', name: 'Motorized wheelchair accessible.', note: 'Do you need a vehicle than has space for a motorized wheelchair?', datatype: 'bool'}, 
#{klass:Accommodation, code: 'door_to_door', name: 'Door-to-door', note: 'Do you need assistance getting to your front door?', datatype: 'bool'},
{klass:Accommodation, code: 'curb_to_curb', name: 'Curb-to-curb', note: 'Do you need delivery to the curb in front of your home?', datatype: 'bool'},
#{klass:Accommodation, code: 'driver_assistance_available', name: 'Driver assistance available.', note: 'Do you need personal assistance from the driver?', datatype: 'bool'},
#Service types 
{klass:ServiceType, code: 'paratransit', name: 'Paratransit', note: 'This is a general purpose paratransit service.'}, 
{klass:ServiceType, code: 'volunteer', name: 'Volunteer', note: 'This is a volunteer service'}, 
{klass:ServiceType, code: 'nemt', name: 'Non-Emergency Medical Service', note: 'This is a paratransit service only to be used for medical trips.'},
{klass: ServiceType, code: 'transit', name: 'Fixed-route Transit', note: 'This is a transit service.'},
{klass: ServiceType, code: 'taxi', name: 'Taxi', note: 'Taxi services.'},
].each do |record|
  structured_hash = structure_records_from_flat_hash record
  build_internationalized_records structured_hash
end

#trip_purposes
# {klass:TripPurpose, code: 'medical', name: 'Medical', note: 'General medical trip.', active: 1, sort_order: 2}, 
# {klass:TripPurpose, code: 'cancer', name: 'Cancer Treatment', note: 'Trip to receive cancer treatment.', active: 1, sort_order: 2}, 
# {klass:TripPurpose, code: 'general', name: 'General Purpose', note: 'General purpose/unspecified purpose.', active: 1, sort_order: 1}, 
#  {klass:TripPurpose, code: 'grocery', name: 'Grocery Trip', note: 'Grocery shopping trip.', active: 1, sort_order: 2}
#  # {klass:TripPurpose, code: 'vamc', name: 'Visit Lebanon VA Medical Center', note: 'Visit Lebanon VA Medical Center', active: 1, sort_order: 2}

['Adult Day Care',
'After School Program',
'Cancer Treatment',
'Dialysis',
'Education',
'General Purpose',
'Grocery',
'Medical',
'Methadone',
'Other',
'Personal Errand',
'Pharmacy',
'Recreation',
'Senior Center',
'Senior Center Group Trip, Recreation',
'Shopping',
'Social Service',
'Training/Employment',
'Volunteer',
'Visit Lebanon VA Medical Center',
'Work'].each do |name|
  record = {klass:TripPurpose, code: name.downcase.gsub(%r{[ /]}, '_'), name: name, note: name, active: 1, sort_order: 2}
  record[:sort_order] = 1 if record[:code]=='general_purpose'
  record[:sort_order] = 3 if record[:code]=='other'
  structured_hash = structure_records_from_flat_hash record
  build_internationalized_records structured_hash
end

# update linked characteristics
age = Characteristic.unscoped.find_by(code: 'age')
dob = Characteristic.unscoped.find_by(code: 'date_of_birth')

dob.update_attributes!(for_service: false, linked_characteristic: age,
                       link_handler: 'AgeCharacteristicHandler') rescue puts "dob.update_attributes! failed"

age.update_attributes!(for_traveler: false, linked_characteristic: dob,
                       link_handler: 'AgeCharacteristicHandler') rescue Rails.logger.warn "age.update_attributes failed!"
