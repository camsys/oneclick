##### Eligibility Seeds #####

#Traveler characteristics

    @disabled = TravelerCharacteristic.create(
      characteristic_type: 'personal_factor', 
      code: 'disabled',
      name: 'Disabled', 
      note: 'Do you have a permanent or temporary disability?',
      datatype: 'bool')
    @no_trans = TravelerCharacteristic.create(
      characteristic_type: 'personal_factor', 
      code: 'no_trans', 
      name: 'No Means of Transportation', 
      note: 'Do you own or have access to a personal vehicle?', 
      datatype: 'bool')
    @nemt_eligible = TravelerCharacteristic.create(
      characteristic_type: 'program', 
      code: 'nemt_eligible', 
      name: 'Medicaid',
      note: 'Are you eligible for Medicaid?', 
      datatype: 'bool')
    @ada_eligible = TravelerCharacteristic.create(
      characteristic_type: 'program', 
      code: 'ada_eligible', 
      name: 'ADA Paratransit',
      note: 'Are you eligible for ADA paratransit?', 
      datatype: 'bool')
    @veteran = TravelerCharacteristic.create(
      characteristic_type: 'personal_factor', 
      code: 'veteran', 
      name: 'Veteran', 
      note: 'Are you a military veteran?', 
      datatype: 'bool')
    @low_income = TravelerCharacteristic.create(
      characteristic_type: 'personal_factor', 
      code: 'low_income', 
      name: 'Low income', 
      note: "Are you low income?", 
      datatype: 'disabled')
    @date_of_birth = TravelerCharacteristic.create(
      characteristic_type: 'personal_factor', 
      code: 'date_of_birth', 
      name: 'Date of Birth', 
      note: "What is your date of birth?", 
      datatype: 'date')
    @age = TravelerCharacteristic.create(
      characteristic_type: 'personal_factor', 
      code: 'age', 
      name: 'Age', 
      note: "What is the traveler's age?", 
      datatype: 'integer')
    @walk_distance = TravelerCharacteristic.create(
      characteristic_type: 'personal_factor', 
      code: 'walk_distance', 
      name: 'Walk distance', 
      note: 'Are you able to comfortably walk for 5, 10, 15, 20, 25, 30 minutes?', 
      datatype: 'disabled')
    

#Traveler accommodations
    @folding_wheelchair_accessible = TravelerAccommodation.create(
      code: 'folding_wheelchair_acceessible', 
      name: 'Folding wheelchair accessible.', 
      note: 'Do you need a vehicle that has space for a folding wheelchair?', 
      datatype: 'bool')
    @motorized_wheelchair_accessible = TravelerAccommodation.create(
      code: 'motorized_wheelchair_accessible', 
      name: 'Motorized wheelchair accessible.', 
      note: 'Do you need a vehicle than has space for a motorized wheelchair?', 
      datatype: 'bool')
    @lift_equipped = TravelerAccommodation.create(
      code: 'lift_equipped', 
      name: 'Wheelchair lift equipped vehicle.', 
      note: 'Do you need a vehicle with a lift?', 
      datatype: 'bool')
    @door_to_door = TravelerAccommodation.create(
      code: 'door_to_door', 
      name: 'Door-to-door', 
      note: 'Do you need assistance getting to your front door?',
      datatype: 'bool')
    @curb_to_curb = TravelerAccommodation.create(
      code: 'curb_to_curb', 
      name: 'Curb-to-curb', 
      note: 'Do you need delivery to the curb in front of your home?', 
      datatype: 'bool')
    @driver_assistance_available = TravelerAccommodation.create(
      code: 'driver_assistance_available', 
      name: 'Driver assistance available.', 
      note: 'Do you need personal assistance from the driver?', 
      datatype: 'bool')

#Service types
    @paratransit = ServiceType.create(
      name: 'Paratransit', 
      note: 'This is a general purpose paratransit service.')
    @volunteer = ServiceType.create(
      name: 'Volunteer', 
      note: '')
    @nemt = ServiceType.create(
      name: 'Non-Emergency Medical Service', 
      note: 'This is a paratransit service only to be used for medical trips.')
    @livery = ServiceType.create(
      name: 'Livery', 
      note: 'Car service for hire.')

#trip_purposes
    @work = TripPurpose.create(
      name: 'Work', 
      note: 'Work-related trip.', 
      active: 1, 
      sort_order: 2)
    @medical = TripPurpose.create(
      name: 'Medical', 
      note: 'General medical trip.', 
      active: 1, 
      sort_order: 2)
    @cancer = TripPurpose.create(
      name: 'Cancer Treatment', 
      note: 'Trip to receive cancer treatment.', 
      active: 1, 
      sort_order: 2)
    @general = TripPurpose.create(
      name: 'General Purpose', 
      note: 'General purpose/unspecified purpose.', 
      active: 1, 
      sort_order: 1)
    @senior = TripPurpose.create(
      name: 'Visit Senior Center',
      note: 'Trip to visit Senior Center.',
      active: 1,
      sort_order: 2)
    @grocery = TripPurpose.create(
      name: 'Grocery Trip',
      note: 'Grocery shopping trip.',
      active: 1,
      sort_order: 2)
