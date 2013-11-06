require File.join(Rails.root, 'db', 'eligibility')

providers = [
    {name: 'BC CS Mass Transit', contact: '', external_id: "1"},
    {name: 'City of Tamarac', contact: '', external_id: "2"},
    {name: 'City of Wilton Manners', contact: ' ', external_id: "3"},
    {name: 'Cooper City Community Services', contact: ' ', external_id: "4"},
    {name: 'City of Miramar', contact: ' ', external_id: "5"},
    {name: 'Southeast Focal Point', contact: ' ', external_id: "6"},
    {name: 'American Cancer Society', contact: ' ', external_id: "7"},
    {name: 'City of Sunrise', contact: ' ', external_id: "8"},
    {name: 'Northwest Focal Point', contact: ' ', external_id: "9"},
    {name: 'City of Lauderdale Lakes', contact: ' ', external_id: "10"}

]

#Create providers and services with custom schedules, eligibility, and accommodations
providers.each do |provider|
  puts "Add/replace provider #{provider[:external_id]}"

  Provider.find_by_external_id(provider[:external_id]).destroy rescue nil
  p = Provider.create! provider
  p.save

  case p.external_id

    when "1" #BC
             #Create service
      service = Service.create(name: 'BC Paratransit', provider: p, service_type: @paratransit, advanced_notice_minutes: 24*60)
      #Add Schedules
      (1..5).each do |n|
        Schedule.create(service: service, start_time:"8:00", end_time: "17:00", day_of_week: n)
      end
      #Trip purpose requirements
      [@senior, @medical, @cancer, @grocery].each do |n|
        ServiceTripPurposeMap.create(service: service, trip_purpose: n, value: 'true')
      end

      #Add geographic restrictions
      ['Broward'].each do |z|
        c = GeoCoverage.new(value: z, coverage_type: 'county_name')
        ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'origin')
      end
      ['Broward'].each do |z|
        c = GeoCoverage.new(value: z, coverage_type: 'county_name')
        ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'destination')
      end

      #Traveler Characteristics Requirements
      ServiceTravelerCharacteristicsMap.create(service: service, traveler_characteristic: @ada_eligible, value: 'true')

      #Traveler Accommodations Requirements
      [@motorized_wheelchair_accessible, @lift_equipped, @door_to_door, @driver_assistance_available, @folding_wheelchair_accessible].each do |n|
        ServiceTravelerAccommodationsMap.create(service: service, traveler_accommodation: n, value: 'true')
      end


    when "2" #Tamarac

      service = Service.create(name: 'Social Services: Limited Transportation', provider: p, service_type: @paratransit, advanced_notice_minutes: 24*60)
      #Add Schedules
      (1..5).each do |n|
        Schedule.create(service: service, start_time:"8:00", end_time: "4:30", day_of_week: n)
      end

      #Trip Purpose Requirements
      [@medical,@grocery, @cancer].each do |n|
        ServiceTripPurposeMap.create(service: service, trip_purpose: n, value: 'true')
      end

      #Add geographic restrictions
      ['33309', '33319', '33320', '33321', '33323', '33351', '33359'].each do |z|
        c = GeoCoverage.new(value: z, coverage_type: 'zipcode')
        ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'origin')
      end

      #Add geographic restrictions
      ['33309', '33319', '33320', '33321', '33323', '33351', '33359'].each do |z|
        c = GeoCoverage.new(value: z, coverage_type: 'zipcode')
        ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'destination')
      end

      #Traveler Characteristics Requirements
      ServiceTravelerCharacteristicsMap.create(service: service, traveler_characteristic: @no_trans, value: 'false')

      #Traveler Accommodations Requirements
      [@curb_to_curb, @folding_wheelchair_accessible].each do |n|
        ServiceTravelerAccommodationsMap.create(service: service, traveler_accommodation: n, value: 'true')
      end

    when "3"   #Wilton Manors

      service = Service.create(name: 'Social Services', provider: p, service_type: @paratransit, advanced_notice_minutes: 24*60)
      #Add Schedules
      (1..5).each do |n|
        Schedule.create(service: service, start_time:"8:00", end_time: "17:00", day_of_week: n)
      end
      #Trip Purpose Requirements
      [@medical, @grocery, @cancer].each do |n|
        ServiceTripPurposeMap.create(service: service, trip_purpose: n, value: 'true')
      end

      #Add geographic restrictions
      ['33305', '33311', '33334'].each do |z|
        c = GeoCoverage.new(value: z, coverage_type: 'zipcode')
        ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'origin')
      end

      ['33305', '33311', '33334'].each do |z|
        c = GeoCoverage.new(value: z, coverage_type: 'zipcode')
        ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'origin')
      end

      ServiceTravelerCharacteristicsMap.create(service: service, traveler_characteristic: disabled, value: 'true')

      #Traveler Accommodations Provided
      [@folding_wheelchair_accessible, @door_to_door].each do |n|
        ServiceTravelerAccommodationsMap.create(service: service, traveler_accommodation: n, value: 'true')
      end

    when "4" #Cooper City

      service = Service.create(name: 'Senior Services Transportation', provider: p, service_type: @paratransit, advanced_notice_minutes: 24*60)
      #Add Schedules
      (1..5).each do |n|
        Schedule.create(service: service, start_time:"9:00", end_time: "17:00", day_of_week: n)
      end

      #Trip Purpose Requirements
      [@medical, @cancer, @grocery, @senior].each do |n|
        ServiceTripPurposeMap.create(service: service, trip_purpose: n, value: 'true')
      end

      #Add geographic restrictions
      ['33024', '33026', '33328', '33329', '33330'].each do |z|
        c = GeoCoverage.new(value: z, coverage_type: 'zipcode')
        ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'origin')
      end

      ['Broward'].each do |z|
        c = GeoCoverage.new(value: z, coverage_type: 'county_name')
        ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'destination')
      end

      #Traveler Characteristics Requirements
      ServiceTravelerCharacteristicsMap.create(service: service, traveler_characteristic: @age, value: '60', value_relationship_id: 4)

      #Traveler Accommodations Requirements
      [@door_to_door, @folding_wheelchair_accessible].each do |n|
        ServiceTravelerAccommodationsMap.create(service: service, traveler_accommodation: n, value: 'true')
      end

    when "5" #City of Miramar
             #
      service = Service.create(name: 'Senior Center', provider: p, service_type: @paratransit, advanced_notice_minutes: 24*60)
      #Add Schedules
      (1..5).each do |n|
        Schedule.create(service: service, start_time:"8:00", end_time: "16:30", day_of_week: n)
      end

      #Trip Purpose Requirements
      [@senior, @cancer, @medical, @grocery].each do |n|
        ServiceTripPurposeMap.create(service: service, trip_purpose: n, value: 'true')
      end

      #Add geographic restrictions
      ['33023', '33025', '33027', '33029'].each do |z|
        c = GeoCoverage.new(value: z, coverage_type: 'zipcode')
        ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'origin')
      end

      ['33023', '33025', '33027', '33029'].each do |z|
        c = GeoCoverage.new(value: z, coverage_type: 'zipcode')
        ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'destination')
      end

      #Traveler Characteristics Requirements
      ServiceTravelerCharacteristicsMap.create(service: service, traveler_characteristic: @age, value: '60', value_relationship_id: 4)

      #Traveler Accommodations Requirements
      [@door_to_door, @folding_wheelchair_accessible].each do |n|
        ServiceTravelerAccommodationsMap.create(service: service, traveler_accommodation: n, value: 'true')
      end

    when "6" # SE Focal Point
             #
      service = Service.create(name: 'Joseph Meyerhoff Senior Center', provider: p, service_type: @paratransit, advanced_notice_minutes: 7*24*60)
      #Add Schedules
      (1..5).each do |n|
        Schedule.create(service: service, start_time:"8:00", end_time: "16:00", day_of_week: n)
      end

      #Trip Purpose Requirements
      [@grocery].each do |n|
        ServiceTripPurposeMap.create(service: service, trip_purpose: n, value: 'true')
      end

      #Add geographic restrictions
      ['33028', '33027', '33330', '33325', '33324', '33313', '33311', '33334', '33308', '33306', '33305', '33304', '33301', '33316', '33315', '33312', '33004', '33317', '33314', '33313', '33312', '333026', '33024', '33004', '33025', '33021', '33023', '33020', '33009', '33019'].each do |z|
        c = GeoCoverage.new(value: z, coverage_type: 'zipcode')
        ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'origin')
      end

      ['33028', '33027', '33330', '33325', '33324', '33313', '33311', '33334', '33308', '33306', '33305', '33304', '33301', '33316', '33315', '33312', '33004', '33317', '33314', '33313', '33312', '333026', '33024', '33004', '33025', '33021', '33023', '33020', '33009', '33019'].each do |z|
        c = GeoCoverage.new(value: z, coverage_type: 'zipcode')
        ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'destination')
      end

      #Traveler Characteristics Requirements
      ServiceTravelerCharacteristicsMap.create(service: service, traveler_characteristic: @age, value: '60', value_relationship_id: 4)

      #Traveler Accommodations Requirements
      [@curb_to_curb, @folding_wheelchair_accessible].each do |n|
        ServiceTravelerAccommodationsMap.create(service: service, traveler_accommodation: n, value: 'true')
      end

    when "7" #American Cancer Society

      service = Service.create(name: 'Road to Recovery', provider: p, service_type: @paratransit, advanced_notice_minutes: 24*60)
      #Add Schedules
      (1..5).each do |n|
        Schedule.create(service: service, start_time:"9:00", end_time: "17:00", day_of_week: n)
      end

      #Trip Purpose Requirements
      [@cancer].each do |n|
        ServiceTripPurposeMap.create(service: service, trip_purpose: n, value: 'true')
      end

      #Add geographic restrictions
      ['broward'].each do |z|
        c = GeoCoverage.new(value: z, coverage_type: 'county_name')
        ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'origin')
      end

      #Add geographic restrictions
      ['broward'].each do |z|
        c = GeoCoverage.new(value: z, coverage_type: 'county_name')
        ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'destination')
      end

      #Traveler Characteristics Requirements
      ServiceTravelerCharacteristicsMap.create(service: service, traveler_characteristic: @no_trans, value: 'false')

      #Traveler Accommodations Requirements
      [@curb_to_curb, @folding_wheelchair_accessible].each do |n|
        ServiceTravelerAccommodationsMap.create(service: service, traveler_accommodation: n, value: 'true')
      end

    when "8" #City of Sunrise

      service = Service.create(name: 'Special & Community Support Services', provider: p, service_type: @paratransit, advanced_notice_minutes: 24*60)
      #Add Schedules
      (1..5).each do |n|
        Schedule.create(service: service, start_time:"8:00", end_time: "17:00", day_of_week: n)
      end

      #Trip Purpose Requirements
      [@medical, @cancer].each do |n|
        ServiceTripPurposeMap.create(service: service, trip_purpose: n, value: 'true')
      end

      #Add geographic restrictions
      ['33304', '33313', '33319', '33321', '33322', '33323', '33325', '33326', '33338', '33345', '33351', '33355'].each do |z|
        c = GeoCoverage.new(value: z, coverage_type: 'zipcode')
        ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'origin')
      end

      ['broward'].each do |z|
        c = GeoCoverage.new(value: z, coverage_type: 'county_name')
        ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'destination')
      end

      #Traveler Characteristics Requirements
      ServiceTravelerCharacteristicsMap.create(service: service, traveler_characteristic: @no_trans, value: 'false')
      ServiceTravelerCharacteristicsMap.create(service: service, traveler_characteristic: @age, value: '62', value_relationship_id: 4)

      #Traveler Accommodations Requirements
      [@curb_to_curb, @folding_wheelchair_accessible].each do |n|
        ServiceTravelerAccommodationsMap.create(service: service, traveler_accommodation: n, value: 'true')
      end

    when "9" #Northwest Focal Center

      service = Service.create(name: 'Senior Medical Transportation', provider: p, service_type: @paratransit, advanced_notice_minutes: 2*24*60)
      #Add Schedules
      (1..5).each do |n|
        Schedule.create(service: service, start_time:"8:00", end_time: "17:00", day_of_week: n)
      end

      #Trip Purpose Requirements
      [@medical, @cancer].each do |n|
        ServiceTripPurposeMap.create(service: service, trip_purpose: n, value: 'true')
      end

      #Add geographic restrictions
      ['33063', '33065', '33093', '33068', '33067', '33073'].each do |z|
        c = GeoCoverage.new(value: z, coverage_type: 'zipcode')
        ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'origin')
      end

      ['33063', '33065', '33093', '33068', '33067', '33073'].each do |z|
        c = GeoCoverage.new(value: z, coverage_type: 'zipcode')
        ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'destination')
      end

      #Traveler Characteristics Requirements
      ServiceTravelerCharacteristicsMap.create(service: service, traveler_characteristic: @age, value: '60', value_relationship_id: 4)

      #Traveler Accommodations Requirements
      [@curb_to_curb, @folding_wheelchair_accessible].each do |n|
        ServiceTravelerAccommodationsMap.create(service: service, traveler_accommodation: n, value: 'true')
      end

    when "10" #City of Lauderdale Lakes

      service = Service.create(name: 'Senior Transport', provider: p, service_type: @paratransit, advanced_notice_minutes: 3*24*60)
      #Add Schedules
      (1..5).each do |n|
        Schedule.create(service: service, start_time:"8:00", end_time: "17:00", day_of_week: n)
      end

      #Trip Purpose Requirements
      [@grocery, @general, @senior, @medical, @cancer].each do |n|
        ServiceTripPurposeMap.create(service: service, trip_purpose: n, value: 'true')
      end

      #Add geographic restrictions
      ['33063', '33068', '33067', '33073'].each do |z|
        c = GeoCoverage.new(value: z, coverage_type: 'zipcode')
        ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'origin')
      end

      ['33063', '33068', '33067', '33073'].each do |z|
        c = GeoCoverage.new(value: z, coverage_type: 'zipcode')
        ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'destination')
      end

      #Traveler Characteristics Requirements
      ServiceTravelerCharacteristicsMap.create(service: service, traveler_characteristic: @age, value: '60', value_relationship_id: 4)

      #Traveler Accommodations Requirements
      [@curb_to_curb, @folding_wheelchair_accessible].each do |n|
        ServiceTravelerAccommodationsMap.create(service: service, traveler_accommodation: n, value: 'true')
      end


      service = Service.create(name: 'Disabled Transport', provider: p, service_type: @paratransit, advanced_notice_minutes: 3*24*60)
      #Add Schedules
      (1..5).each do |n|
        Schedule.create(service: service, start_time:"9:00", end_time: "12:00", day_of_week: n)
      end

      #Trip Purpose Requirements
      [@grocery, @general, @senior, @medical, @cancer].each do |n|
        ServiceTripPurposeMap.create(service: service, trip_purpose: n, value: 'true')
      end

      #Add geographic restrictions
      ['33063', '33068', '33067', '33073'].each do |z|
        c = GeoCoverage.new(value: z, coverage_type: 'zipcode')
        ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'origin')
      end

      ['33063', '33068', '33067', '33073'].each do |z|
        c = GeoCoverage.new(value: z, coverage_type: 'zipcode')
        ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'destination')
      end

      #Traveler Characteristics Requirements
      ServiceTravelerCharacteristicsMap.create(service: service, traveler_characteristic: disabled, value: 'true')

      #Traveler Accommodations Requirements
      [@curb_to_curb, @folding_wheelchair_accessible].each do |n|
        ServiceTravelerAccommodationsMap.create(service: service, traveler_accommodation: n, value: 'true')
      end


  end

end

