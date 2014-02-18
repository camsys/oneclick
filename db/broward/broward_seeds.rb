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
    disabled = Characteristic.create(
      characteristic_type: 'personal_factor', 
      code: 'disabled',
      name: 'Disabled', 
      note: 'Do you have a permanent or temporary disability?',
      datatype: 'bool')
    no_trans = Characteristic.create(
      characteristic_type: 'personal_factor', 
      code: 'no_trans', 
      name: 'No Means of Transportation', 
      note: 'Do you own or have access to a personal vehicle?', 
      datatype: 'bool')
    nemt_eligible = Characteristic.create(
      characteristic_type: 'program', 
      code: 'nemt_eligible', 
      name: 'Medicaid',
      note: 'Are you eligible for Medicaid?', 
      datatype: 'bool')
    ada_eligible = Characteristic.create(
      characteristic_type: 'program', 
      code: 'ada_eligible', 
      name: 'ADA Paratransit',
      note: 'Are you eligible for ADA paratransit?', 
      datatype: 'bool')
    veteran = Characteristic.create(
      characteristic_type: 'personal_factor', 
      code: 'veteran', 
      name: 'Veteran', 
      note: 'Are you a military veteran?', 
      datatype: 'bool')
    low_income = Characteristic.create(
      characteristic_type: 'personal_factor', 
      code: 'low_income', 
      name: 'Low income', 
      note: "Are you low income?", 
      datatype: 'disabled')
    date_of_birth = Characteristic.create(
      characteristic_type: 'personal_factor', 
      code: 'date_of_birth', 
      name: 'Date of Birth', 
      note: "What is your date of birth?", 
      datatype: 'date')
    age = Characteristic.create(
      characteristic_type: 'personal_factor', 
      code: 'age', 
      name: 'Age', 
      note: "What is the traveler's age?", 
      datatype: 'integer')
    walk_distance = Characteristic.create(
      characteristic_type: 'personal_factor', 
      code: 'walk_distance', 
      name: 'Walk distance', 
      note: 'Are you able to comfortably walk for 5, 10, 15, 20, 25, 30 minutes?', 
      datatype: 'disabled')
    

#Traveler accommodations
    folding_wheelchair_accessible = Accommodation.create(
      code: 'folding_wheelchair_accessible',
      name: 'Folding wheelchair accessible.', 
      note: 'Do you need a vehicle that has space for a folding wheelchair?', 
      datatype: 'bool')
    motorized_wheelchair_accessible = Accommodation.create(
      code: 'motorized_wheelchair_accessible', 
      name: 'Motorized wheelchair accessible.', 
      note: 'Do you need a vehicle than has space for a motorized wheelchair?', 
      datatype: 'bool')
    lift_equipped = Accommodation.create(
      code: 'lift_equipped', 
      name: 'Wheelchair lift equipped vehicle.', 
      note: 'Do you need a vehicle with a lift?', 
      datatype: 'bool')
    door_to_door = Accommodation.create(
      code: 'door_to_door', 
      name: 'Door-to-door', 
      note: 'Do you need assistance getting to your front door?',
      datatype: 'bool')
    curb_to_curb = Accommodation.create(
      code: 'curb_to_curb', 
      name: 'Curb-to-curb', 
      note: 'Do you need delivery to the curb in front of your home?', 
      datatype: 'bool')
    driver_assistance_available = Accommodation.create(
      code: 'driver_assistance_available', 
      name: 'Driver assistance available.', 
      note: 'Do you need personal assistance from the driver?', 
      datatype: 'bool')

#Service types
    paratransit = ServiceType.create(
      code: 'paratransit',
      name: 'Paratransit', 
      note: 'This is a general purpose paratransit service.')
    volunteer = ServiceType.create(
      code: 'volunteer',
      name: 'Volunteer', 
      note: '')
    nemt = ServiceType.create(
      code: 'nemt',
      name: 'Non-Emergency Medical Service', 
      note: 'This is a paratransit service only to be used for medical trips.')

#trip_purposes
    work = TripPurpose.create(
      code: 'work',
      name: 'Work', 
      note: 'Work-related trip.', 
      active: 1, 
      sort_order: 2)
    medical = TripPurpose.create(
      code: 'medical',
      name: 'Medical', 
      note: 'General medical trip.', 
      active: 1, 
      sort_order: 2)
    cancer = TripPurpose.create(
      code: 'cancer',
      name: 'Cancer Treatment', 
      note: 'Trip to receive cancer treatment.', 
      active: 1, 
      sort_order: 2)
    general = TripPurpose.create(
      code: 'general',
      name: 'General Purpose', 
      note: 'General purpose/unspecified purpose.', 
      active: 1, 
      sort_order: 1)
    senior = TripPurpose.create(
      code: 'senior',
      name: 'Visit Senior Center',
      note: 'Trip to visit Senior Center.',
      active: 1,
      sort_order: 2)
    grocery = TripPurpose.create(
      code: 'grocery',
      name: 'Grocery Trip',
      note: 'Grocery shopping trip.',
      active: 1,
      sort_order: 2)



