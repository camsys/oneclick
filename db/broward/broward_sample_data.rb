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

def add_users_and_places
  places = [
    {active: 1, name: 'My house', raw_address: '730 Peachtree St NE, Atlanta, GA 30308'},
    {active: 1, name: 'Atlanta VA Medical Center', raw_address: '1670 Clairmont Rd, Decatur, GA'},
    {active: 1, name: 'Formación Para el Trabajo', raw_address: '239 West Lake Avenue NW, Atlanta, GA 30314'},
    {active: 1, name: 'Atlanta Mission',  raw_address: '239 West Lake Avenue NW, Atlanta, GA 30314'}
  ]
  users = [
    {first_name: 'Denis', last_name: 'Haskin', email: 'dhaskin@camsys.com'},
    {first_name: 'Derek', last_name: 'Edwards', email: 'dedwards@camsys.com'},
    {first_name: 'Eric', last_name: 'Ziering', email: 'eziering@camsys.com'},
    {first_name: 'Galina', last_name: 'Dymkova', email: 'gdymkova@camsys.com'},
    {first_name: 'Aaron', last_name: 'Magil', email: 'amagil@camsys.com'},
    {first_name: 'Julian', last_name: 'Ray', email: 'jray@camsys.com'},
  ]

  users.each do |user|


    u = User.find_by_email(user[:email])
    unless u.nil?
      next
    end

    puts "Add user #{user[:email]}"

    u = User.create! user.merge({password: 'welcome1'})
    up = UserProfile.new
    up.user = u
    up.save!
    places.each do |place|
      p = Place.new(place)
      p.creator = u
      p.geocode
      u.places << p
      begin
        u.save!
      rescue Exception => e
        puts e.inspect
        puts u.errors.inspect
        u.places.each do |pl|
          puts pl.errors.inspect
        end
      end
    end
    Mode.all.each do |mode|
      ump = UserModePreference.new
      ump.user = u
      ump.mode = mode
      ump.save!
    end
    u.add_role :registered_traveler
  end
end

def add_services_and_providers
  disabled = Characteristic.find_by_code('disabled')
  no_trans = Characteristic.find_by_code('no_trans')
  ada_eligible = Characteristic.find_by_code('ada_eligible')
  age = Characteristic.find_by_code('age')
  date_of_birth = Characteristic.find_by_code('date_of_birth')
  
  #Remove any unused characteristics for PA from previous loads
  %w(nemt_eligible veteran low_income walk_distance).each do |unused|
    if c = Characteristic.find_by_code(unused)
      c.destroy
    end
  end
  #Traveler accommodations
  folding_wheelchair_accessible = Accommodation.find_by_code('folding_wheelchair_accessible')
  motorized_wheelchair_accessible = Accommodation.find_by_code('motorized_wheelchair_accessible')
  lift_equipped = Accommodation.find_by_code('lift_equipped')
  door_to_door = Accommodation.find_by_code('door_to_door')
  curb_to_curb = Accommodation.find_by_code('curb_to_curb')
  driver_assistance_available = Accommodation.find_by_code('driver_assistance_available')

  #Service types
  paratransit = ServiceType.find_by_code('paratransit')
  volunteer = ServiceType.find_by_code('volunteer')
  nemt = ServiceType.find_by_code('nemt')

  #trip_purposes
  work = TripPurpose.find_by_code('work')
  training = TripPurpose.find_by_code('training')
  medical = TripPurpose.find_by_code('medical')
  dialysis = TripPurpose.find_by_code('dialysis')
  cancer = TripPurpose.find_by_code('cancer')
  personal = TripPurpose.find_by_code('personal')
  general = TripPurpose.find_by_code('general')
  senior = TripPurpose.find_by_code('senior')
  grocery = TripPurpose.find_by_code('grocery')

  providers = [
      {name: 'BC CS Mass Transit', contact: 'BC Contact', external_id: "1"},
      {name: 'City of Tamarac', contact: 'Tamarac Contact', external_id: "2"},
      {name: 'City of Wilton Manners', contact: 'WM Contact ', external_id: "3"},
      {name: 'Cooper City Community Services', contact: 'CC Contact ', external_id: "4"},
      {name: 'City of Miramar', contact: 'Miramar Contact ', external_id: "5"},
      {name: 'Southeast Focal Point', contact: 'SEFP Contact ', external_id: "6"},
      {name: 'American Cancer Society', contact: 'ACS Contact ', external_id: "7"},
      {name: 'City of Sunrise', contact: 'Sunrise Contact ', external_id: "8"},
      {name: 'Northwest Focal Point', contact: 'NWFP Contact ', external_id: "9"},
      {name: 'City of Lauderdale Lakes', contact: 'LL Contact ', external_id: "10"},
      {name: 'Miami-Dade Transit', contact: "MD Contact", external_id: "11"},
      {name: 'Palm Tran', contact: "PT Contact", external_id: "12"}

  ]

  #Create providers and services with custom schedules, eligibility, and accommodations
  providers.each do |provider|

    puts "Add/replace provider #{provider[:external_id]}"

    p = Provider.find_by_external_id(provider[:external_id])
    unless p.nil?
      next
    end

    contact = provider.delete(:contact)
    (first_name, last_name) = contact.split(/ /, 2)
    p = Provider.create! provider
    p.save

    puts contact.downcase.gsub(' ', '_').gsub(%r{\W}, '') + '@camsys.com'
    email = contact.downcase.gsub(' ', '_').gsub(%r{\W}, '') + '@camsys.com'
    u = User.where(email: email).first
    if u.nil?
      u = User.create! first_name: first_name, last_name: last_name,
          email: contact.downcase.gsub(' ', '_').gsub(%r{\W}, '') + '@camsys.com', password: 'welcome1'
      up = UserProfile.create! user: u
      # p.users << u
      u.add_role :internal_contact, p
    end

    case p.external_id

      when "1" #BC
               #Create service
        service = Service.create(name: 'TOPS', provider: p, service_type: paratransit, advanced_notice_minutes: 24*60)
        #Add Schedules
        (1..5).each do |n|
          Schedule.create(service: service, start_time:"8:00", end_time: "17:00", day_of_week: n)
        end
        #Trip purpose requirements
        [senior, medical, cancer, grocery].each do |n|
          ServiceTripPurposeMap.create(service: service, trip_purpose: n)
        end

        #Add geographic restrictions
        ['Broward'].each do |z|
          c = GeoCoverage.find_or_create_by(value: z, coverage_type: 'county_name')
          ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'endpoint_area')
        end
        ['Broward'].each do |z|
          c = GeoCoverage.find_or_create_by(value: z, coverage_type: 'county_name')
          ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'coverage_area')
        end


        #Traveler Characteristics Requirements
        ServiceCharacteristic.create(service: service, characteristic: ada_eligible, value: 'true')

        #Traveler Accommodations Requirements
        [motorized_wheelchair_accessible, lift_equipped, door_to_door, driver_assistance_available, folding_wheelchair_accessible].each do |n|
          ServiceAccommodation.create(service: service, accommodation: n)
        end


      when "2" #Tamarac

        service = Service.create(name: 'Social Services: Limited Transportation', provider: p, service_type: paratransit, advanced_notice_minutes: 24*60)
        #Add Schedules
        (1..5).each do |n|
          Schedule.create(service: service, start_time:"8:00", end_time: "4:30", day_of_week: n)
        end

        #Trip Purpose Requirements
        [medical,grocery, cancer].each do |n|
          ServiceTripPurposeMap.create(service: service, trip_purpose: n)
        end

        #Add geographic restrictions
        ['33309', '33319', '33320', '33321', '33323', '33351', '33359'].each do |z|
          c = GeoCoverage.find_or_create_by(value: z, coverage_type: 'zipcode')
          ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'endpoint_area')
        end

        #Add geographic restrictions
        ['33309', '33319', '33320', '33321', '33323', '33351', '33359'].each do |z|
          c = GeoCoverage.find_or_create_by(value: z, coverage_type: 'zipcode')
          ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'coverage_area')
        end

        #Traveler Characteristics Requirements
        ServiceCharacteristic.create(service: service, characteristic: no_trans, value: 'false')

        #Traveler Accommodations Requirements
        [curb_to_curb, folding_wheelchair_accessible].each do |n|
          ServiceAccommodation.create(service: service, accommodation: n)
        end

      when "3"   #Wilton Manors

        service = Service.create(name: 'Social Services', provider: p, service_type: paratransit, advanced_notice_minutes: 24*60)
        #Add Schedules
        (1..5).each do |n|
          Schedule.create(service: service, start_time:"8:00", end_time: "17:00", day_of_week: n)
        end
        #Trip Purpose Requirements
        [medical, grocery, cancer].each do |n|
          ServiceTripPurposeMap.create(service: service, trip_purpose: n)
        end

        #Add geographic restrictions
        ['33305', '33311', '33334'].each do |z|
          c = GeoCoverage.find_or_create_by(value: z, coverage_type: 'zipcode')
          ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'endpoint_area')
        end

        ['33305', '33311', '33334'].each do |z|
          c = GeoCoverage.find_or_create_by(value: z, coverage_type: 'zipcode')
          ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'coverage_area')
        end

        ServiceCharacteristic.create(service: service, characteristic: disabled, value: 'true')

        #Traveler Accommodations Provided
        [folding_wheelchair_accessible, door_to_door].each do |n|
          ServiceAccommodation.create(service: service, accommodation: n)
        end

      when "4" #Cooper City

        service = Service.create(name: 'Senior Services Transportation', provider: p, service_type: paratransit, advanced_notice_minutes: 24*60)
        #Add Schedules
        (1..5).each do |n|
          Schedule.create(service: service, start_time:"9:00", end_time: "17:00", day_of_week: n)
        end

        #Trip Purpose Requirements
        [medical, cancer, grocery, senior].each do |n|
          ServiceTripPurposeMap.create(service: service, trip_purpose: n)
        end

        #Add geographic restrictions
        ['33024', '33026', '33328', '33329', '33330'].each do |z|
          c = GeoCoverage.find_or_create_by(value: z, coverage_type: 'zipcode')
          ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'endpoint_area')
        end

        ['Broward'].each do |z|
          c = GeoCoverage.find_or_create_by(value: z, coverage_type: 'county_name')
          ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'coverage_area')
        end

        #Traveler Characteristics Requirements
        ServiceCharacteristic.create(service: service, characteristic: age, value: '60', rel_code: 4)

        #Traveler Accommodations Requirements
        [door_to_door, folding_wheelchair_accessible].each do |n|
          ServiceAccommodation.create(service: service, accommodation: n)
        end

      when "5" #City of Miramar
               #
        service = Service.create(name: 'Senior Center', provider: p, service_type: paratransit, advanced_notice_minutes: 24*60)
        #Add Schedules
        (1..5).each do |n|
          Schedule.create(service: service, start_time:"8:00", end_time: "16:30", day_of_week: n)
        end

        #Trip Purpose Requirements
        [senior, cancer, medical, grocery].each do |n|
          ServiceTripPurposeMap.create(service: service, trip_purpose: n)
        end

        #Add geographic restrictions
        ['33023', '33025', '33027', '33029'].each do |z|
          c = GeoCoverage.find_or_create_by(value: z, coverage_type: 'zipcode')
          ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'endpoint_area')
        end

        ['33023', '33025', '33027', '33029'].each do |z|
          c = GeoCoverage.find_or_create_by(value: z, coverage_type: 'zipcode')
          ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'coverage_area')
        end

        #Traveler Characteristics Requirements
        ServiceCharacteristic.create(service: service, characteristic: age, value: '60', rel_code: 4)

        #Traveler Accommodations Requirements
        [door_to_door, folding_wheelchair_accessible].each do |n|
          ServiceAccommodation.create(service: service, accommodation: n)
        end

      when "6" # SE Focal Point
               #
        service = Service.create(name: 'Joseph Meyerhoff Senior Center', provider: p, service_type: paratransit, advanced_notice_minutes: 7*24*60)
        #Add Schedules
        (1..5).each do |n|
          Schedule.create(service: service, start_time:"8:00", end_time: "16:00", day_of_week: n)
        end

        #Trip Purpose Requirements
        [grocery].each do |n|
          ServiceTripPurposeMap.create(service: service, trip_purpose: n)
        end

        #Add geographic restrictions
        ['33028', '33027', '33330', '33325', '33324', '33313', '33311', '33334', '33308', '33306', '33305', '33304', '33301', '33316', '33315', '33312', '33004', '33317', '33314', '33313', '33312', '333026', '33024', '33004', '33025', '33021', '33023', '33020', '33009', '33019'].each do |z|
          c = GeoCoverage.find_or_create_by(value: z, coverage_type: 'zipcode')
          ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'endpoint_area')
        end

        ['33028', '33027', '33330', '33325', '33324', '33313', '33311', '33334', '33308', '33306', '33305', '33304', '33301', '33316', '33315', '33312', '33004', '33317', '33314', '33313', '33312', '333026', '33024', '33004', '33025', '33021', '33023', '33020', '33009', '33019'].each do |z|
          c = GeoCoverage.find_or_create_by(value: z, coverage_type: 'zipcode')
          ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'coverage_area')
        end

        #Traveler Characteristics Requirements
        ServiceCharacteristic.create(service: service, characteristic: age, value: '60', rel_code: 4)

        #Traveler Accommodations Requirements
        [curb_to_curb, folding_wheelchair_accessible].each do |n|
          ServiceAccommodation.create(service: service, accommodation: n)
        end

      when "7" #American Cancer Society

        service = Service.create(name: 'Road to Recovery', provider: p, service_type: paratransit, advanced_notice_minutes: 24*60)
        #Add Schedules
        (1..5).each do |n|
          Schedule.create(service: service, start_time:"9:00", end_time: "17:00", day_of_week: n)
        end

        #Trip Purpose Requirements
        [cancer].each do |n|
          ServiceTripPurposeMap.create(service: service, trip_purpose: n)
        end

        #Add geographic restrictions
        ['broward'].each do |z|
          c = GeoCoverage.find_or_create_by(value: z, coverage_type: 'county_name')
          ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'endpoint_area')
        end

        #Add geographic restrictions
        ['broward'].each do |z|
          c = GeoCoverage.find_or_create_by(value: z, coverage_type: 'county_name')
          ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'coverage_area')
        end

        #Traveler Characteristics Requirements
        ServiceCharacteristic.create(service: service, characteristic: no_trans, value: 'false')

        #Traveler Accommodations Requirements
        [curb_to_curb, folding_wheelchair_accessible].each do |n|
          ServiceAccommodation.create(service: service, accommodation: n)
        end

      when "8" #City of Sunrise

        service = Service.create(name: 'Special & Community Support Services', provider: p, service_type: paratransit, advanced_notice_minutes: 24*60)
        #Add Schedules
        (1..5).each do |n|
          Schedule.create(service: service, start_time:"8:00", end_time: "17:00", day_of_week: n)
        end

        #Trip Purpose Requirements
        [medical, cancer].each do |n|
          ServiceTripPurposeMap.create(service: service, trip_purpose: n)
        end

        #Add geographic restrictions
        ['33304', '33313', '33319', '33321', '33322', '33323', '33325', '33326', '33338', '33345', '33351', '33355'].each do |z|
          c = GeoCoverage.find_or_create_by(value: z, coverage_type: 'zipcode')
          ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'endpoint_area')
        end

        ['broward'].each do |z|
          c = GeoCoverage.find_or_create_by(value: z, coverage_type: 'county_name')
          ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'coverage_area')
        end

        #Traveler Characteristics Requirements
        ServiceCharacteristic.create(service: service, characteristic: no_trans, value: 'false')
        ServiceCharacteristic.create(service: service, characteristic: age, value: '62', rel_code: 4)

        #Traveler Accommodations Requirements
        [curb_to_curb, folding_wheelchair_accessible].each do |n|
          ServiceAccommodation.create(service: service, accommodation: n)
        end

      when "9" #Northwest Focal Center

        service = Service.create(name: 'Senior Medical Transportation', provider: p, service_type: paratransit, advanced_notice_minutes: 2*24*60)
        #Add Schedules
        (1..5).each do |n|
          Schedule.create(service: service, start_time:"8:00", end_time: "17:00", day_of_week: n)
        end

        #Trip Purpose Requirements
        [medical, cancer].each do |n|
          ServiceTripPurposeMap.create(service: service, trip_purpose: n)
        end

        #Add geographic restrictions
        ['33063', '33065', '33093', '33068', '33067', '33073'].each do |z|
          c = GeoCoverage.find_or_create_by(value: z, coverage_type: 'zipcode')
          ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'endpoint_area')
        end

        ['33063', '33065', '33093', '33068', '33067', '33073'].each do |z|
          c = GeoCoverage.find_or_create_by(value: z, coverage_type: 'zipcode')
          ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'coverage_area')
        end

        #Traveler Characteristics Requirements
        ServiceCharacteristic.create(service: service, characteristic: age, value: '60', rel_code: 4)

        #Traveler Accommodations Requirements
        [curb_to_curb, folding_wheelchair_accessible].each do |n|
          ServiceAccommodation.create(service: service, accommodation: n)
        end

      when "11"
        #Create service
        service = Service.create(name: 'Special Transportation Service (STS)', provider: p, service_type: paratransit, advanced_notice_minutes: 24*60)
        #Add Schedules
        #Add Schedules
        (0..6).each do |n|
          Schedule.create(service: service, start_seconds:0, end_seconds: 24*3600-1, day_of_week: n)
        end

        #Add geographic restrictions
        ['Dade'].each do |z|
          c = GeoCoverage.find_or_create_by(value: z, coverage_type: 'county_name')
          ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'endpoint_area')
        end
        ['Dade'].each do |z|
          c = GeoCoverage.find_or_create_by(value: z, coverage_type: 'county_name')
          ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'coverage_area')
        end

        if service and service.fare_structures.count == 0
          FareStructure.create(service: service, fare_type: 0, base: 3.50)
        end

        #Traveler Characteristics Requirements
        ServiceCharacteristic.create(service: service, characteristic: ada_eligible, value: 'true')

        #Traveler Accommodations Requirements
        [lift_equipped, door_to_door, folding_wheelchair_accessible].each do |n|
          ServiceAccommodation.create(service: service, accommodation: n)
        end

      when "12"
        #Create service
        service = Service.create(name: 'Palm Tran CONNECTION', provider: p, service_type: paratransit, advanced_notice_minutes: 24*60)
          #Add Schedules
          #Add Schedules
          (1..6).each do |n|
            Schedule.create(service: service, start_seconds:7*3600, end_seconds: 17*3600, day_of_week: n)
          end
          Schedule.create(service: service, start_seconds:8*3600, end_seconds: 17*3600, day_of_week: 0)

          #Add geographic restrictions
          ['Palm Beach'].each do |z|
            c = GeoCoverage.find_or_create_by(value: z, coverage_type: 'county_name')
            ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'endpoint_area')
          end
          ['Palm Beach'].each do |z|
            c = GeoCoverage.find_or_create_by(value: z, coverage_type: 'county_name')
            ServiceCoverageMap.create(service: service, geo_coverage: c, rule: 'coverage_area')
          end

          if service and service.fare_structures.count == 0
            FareStructure.create(service: service, fare_type: 0, base: 3.50)
          end

          #Traveler Characteristics Requirements
          ServiceCharacteristic.create(service: service, characteristic: ada_eligible, value: 'true')

          #Traveler Accommodations Requirements
          [lift_equipped, door_to_door, folding_wheelchair_accessible].each do |n|
            ServiceAccommodation.create(service: service, accommodation: n)
          end
    end
  end
end

def add_fares
  service = Service.find_by_name('TOPS')
  if service and service.fare_structures.count == 0
    FareStructure.create(service: service, fare_type: 0, base: 3.50)

  end

  service = Service.find_by_name('Social Services: Limited Transportation')
  if service and service.fare_structures.count == 0
    FareStructure.create(service: service, fare_type: 0, base: 0, desc: "Tamarac Para-transit fee is $30.00 for 3 months or 40.00 for 6 months per person for unlimited marketing and medical transportation.")

  end

  service = Service.find_by_name('Social Services')
  if service and service.fare_structures.count == 0
    FareStructure.create(service: service, fare_type: 0, base: 1)

  end

  service = Service.find_by_name('Joseph Meyerhoff Senior Center')
  if service and service.fare_structures.count == 0
    FareStructure.create(service: service, fare_type: 0, base: 0, desc: "Free service for Senior Center members.")

  end

  service = Service.find_by_name('Senior Medical Transportation')
  if service and service.fare_structures.count == 0
    FareStructure.create(service: service, fare_type: 0, base: 0, desc: "Free service for Senior Center members.")
  end

  service = Service.find_by_name('Road to Recovery')
  if service and service.fare_structures.count == 0
    FareStructure.create(service: service, fare_type: 0, base: 0)

  end

  service = Service.find_by_name('Special & Community Support Services')
  if service and service.fare_structures.count == 0
    FareStructure.create(service: service, fare_type: 0, base: 3)
  end

  service = Service.find_by_name('Senior Services Transportation')
  if service and service.fare_structures.count == 0
    FareStructure.create(service: service, fare_type: 0, base: 0)
  end

  service = Service.find_by_name('Senior Center')
  if service and service.fare_structures.count == 0
    FareStructure.create(service: service, fare_type: 0, base: 0)
  end
end


def setup_cms
    I18n.available_locales.each do |locale|
      Translation.where(key: 'splash', locale: locale).first_or_create(value: File.open(File.join('db', 'broward', 'splash_' + locale.to_s + '.html')).read)
    end
end

def create_agencies
  ['211 Miami'].each do |a|
    agency = Agency.find_by_name(a)
    unless agency.nil?
      next
    end
    puts "Creating #{a.ai}"
    agency = Agency.create! name: a

    # agency admin
    u = User.create! first_name: a + ' Agency Admin', last_name: 'Agency Admin',
        email: a.downcase.gsub(/ /, '_') + '_admin@camsys.com', password: 'welcome1'
    up = UserProfile.create! user: u
    agency.users << u
    u.add_role :agency_administrator, agency
    u.add_role :internal_contact, agency

    # agency agent
    u = User.create! first_name: a + ' Agent', last_name: 'Agent',
        email: a.downcase.gsub(/ /, '_') + '_agent@camsys.com', password: 'welcome1'
    up = UserProfile.create! user: u
    agency.users << u
    u.add_role :agent, agency
  end
end

def add_ancillary_services
  p = Provider.where(external_id: 'tri-rail').first_or_create
  p.name = 'Tri-Rail'
  p.url ='http://www.tri-rail.com/'
  p.save

  s = ServiceType.where(code: 'transit').first
  service = Service.where(provider: p, service_type: s, external_id: 'tri-rail').first_or_create
  service.name = ""
  service.active = false
  service.save

  provider = Provider.find_or_create_by!({name: 'Taxi services'})
  provider.services.find_or_create_by!({name: 'Taxi services', active: false,
      service_type: ServiceType.where(code: 'taxi').first})
end

def add_contact_info

  #Miami Dade STS
  p = Provider.find_by_external_id('11')
  p.phone = "(786) 469-5000"
  p.url = "www.miamidade.gov/transit"
  p.save
  service = p.services.first
  service.url = "http://www.miamidade.gov/transit/special-transportation-overview.asp"
  service.internal_contact_name = "Marcos Ortega"
  service.internal_contact_email = "mo7225@miamidade.gov"
  service.internal_contact_title = "MDT ADA Coordinator"
  service.internal_contact_phone = ""

  service.phone = "(305) 871-1111"
  service.save

  #Palm Tran Connection
  p = Provider.find_by_external_id('12')
  p.url = "www.palmtran.org"
  p.save
  service = p.services.first
  service.url = "http://www.pbcgov.com/palmtran/information/connection.htm"
  service.internal_contact_name = ""
  service.internal_contact_email = ""
  service.internal_contact_title = "Director of Palm Tran CONNECTION"
  service.internal_contact_phone = "(561) 649-9838"

  service.phone = "(561) 649-9838"
  service.save

  #Broward
  p = Provider.find_by_external_id('1')
  p.phone = "(954) 357-6794"
  p.url = "www.broward.org/bct"
  p.save
  service = p.services.first
  service.url = "https://www.broward.org/BCT/Pages/Paratransit.aspx"
  service.internal_contact_name = ""
  service.internal_contact_email = ""
  service.internal_contact_title = "Directory of Broward County TOPS"
  service.internal_contact_phone = "(866) 682-2258"

  service.phone = "(866) 682-2258"
  service.save


end

add_users_and_places
add_services_and_providers
add_fares
setup_cms
create_agencies
add_ancillary_services
add_contact_info