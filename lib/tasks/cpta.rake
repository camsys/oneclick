
namespace :oneclick do

  desc "Ecolane Help"
  task ecolane_help: :environment do
    puts "Don't forget to change external_id of york to rabbit"
    puts "run rake oneclick:create_api_guest to create the designated guest for api users (prevents thousands of new guests from being created"
    puts "run rake oneclick:create_ecolane_services to create the services."
    puts "After that, run rake oneclick:setup_ecolane_services to setup the ecolane funding sources/sponsors, test users, etc."
    puts "After that you will need to manually add the tokens. A list of services that need tokens will be printed."
    puts "FYI: It's ok to run any of these commands multiple times.  They are idempotent."

    puts 'OPTIONAL: To test the new API fare calls, you can create a test service to replace the Rabbit Shared Ride Service'
    puts 'To do this run: rake oneclick:turn_on_test_service'
    puts 'To turn off the test service and turn the real service back on run: rake oneclick:turn_off_test_service'
  end

  desc "Create API Guest User"
  task create_api_guest: :environment do

    user = User.find_or_create_by(api_guest: true) do |api_guest|
      api_guest.first_name = "API"
      api_guest.last_name = "Guest"
      api_guest.email = "APIGuest@camsys.com"
      new_password = SecureRandom.hex
      api_guest.password = new_password
      api_guest.password_confirmation = new_password
    end

    user.save

  end

  desc "Create Ecolane Services"
  task create_ecolane_services: :environment do
    puts 'Creating the following services'
    ecolane_services =
     [{name: "Rabbit Shared Ride", external_id: "rabbit"},
      {name: "Shared Ride", external_id: "lebanon"},
      {name: "Shared Ride", external_id: "cambria"},
      {name: "Shared Ride", external_id: "franklin"},
      {name: "Shared Ride", external_id: "dauphin"},
      {name: "Shared Ride", external_id: "northumberland"},
      {name: "Shared Ride", external_id: "montour"},
      {name: "Shared Ride", external_id: "unionsnyder"},
      {name: "Shared Ride", external_id: "blair"},
      {name: "Shared Ride", external_id: "monroe"},
      {name: "Shared Ride", external_id: "carbon"},
      {name: "Lehigh Shared Ride", external_id: "lanta"},
      {name: "Northampton Shared Ride", external_id: "lanta"},
      {name: "Shared Ride", external_id: "columbia"}
    ]

    puts ecolane_services.ai

    service_type = ServiceType.find_by(code: "paratransit")

    ecolane_services.each do |ecolane_service|

      # Look up service by external id and create if none exists
      service = Service.find_or_create_by(external_id: ecolane_service[:external_id]) do |service|
        puts 'Creating a new service for ' + ecolane_service.as_json.to_s
        service.service_type = service_type
        service.name = ecolane_service[:name]
      end

      # Create a new provider for service if none exists
      service.provider ||= Provider.find_or_create_by(name: "#{ecolane_service[:external_id].titleize}") do |provider|
        puts "Creating a new provider for service, called #{provider.name}."
      end

      service.booking_profile = BookingServices::AGENCY[:ecolane]
      service.save
    end

    puts 'now run oneclick:setup_ecolane_services to setup the ecolane configs'

  end

  desc "Setup Ecolane Services"
  task setup_ecolane_services: :environment do

    #Before running this task:  For each service with ecolane booking, set the Service Id to the lowercase county name
    #and set the Booking Service Code to 'ecolane' These fields are found on the service profile page

    puts 'Setting up Ecolane Services.  In order for services to be setup for ecolane, they must 1) exist and 2) have their booking code set to ecolane.'

    #Define which funding_sources are ADA, used for determining the questions
    oc = OneclickConfiguration.where(code: "ada_funding_sources").first_or_create
    oc.value = ["ADAYORK1", "ADA"]
    puts 'The following funding sources are considered to be ADA'
    puts oc.value
    oc.save

    services = Service.where(booking_profile: BookingServices::AGENCY[:ecolane])

    services.each do |service|

      #Funding source array cheat sheet
      # 0: code
      # 1: index (lower gives higher priority when trying to match funding sources to trip purposes)
      # 2: general_public (is the the general public funding source?)
      # 3: comment

      #Sponsor array cheat sheet
      # 0: code
      # 1: index

      funding_source_array = []
      sponsor_array = []
      primary_coverage_counties = []
      secondary_coverage_counties = []

      if service
        external_id = service.external_id
        puts 'Setting up ' + ( service.name || service.id.to_s ) + ' for ' +  external_id

        case external_id
        when 'rabbit'

          #Counties
          primary_coverage_counties = ['York', 'Adams', 'Cumberland', 'Perry']
          secondary_coverage_counties = ['York', 'Adams', 'Cumberland', 'Dauphin', 'Franklin', 'Lebanon', 'Perry']

          #Funding Sources
          funding_source_array = [['Lottery', 0, false, 'Riders 65 or older'], ['Lottery [21]', 0, false, 'Riders 65 or older'], ['PWD', 1, false, "Riders with disabilities"], ['MATP', 2, false, "Medical Transportation"], ["ADAYORK1", 3, false, "Eligible for ADA"], ["Gen Pub", 5, true, "Full Fare"]]

          #Sponsors
          sponsor_array = [['MATP', 0],['YCAAA', 1]]

          #Dummy User
          service.fare_user = "79109"

          #Get or create the ecolane_profile
          ecolane_profile = EcolaneProfile.find_or_create_by(service: service)

          #Optional: Disallowed Trip Purposes
          #this is a comma separated string with no spaces around the commas, and all lower-case
          ecolane_profile.disallowed_purposes_text = 'ma urgent care,day care (16),outpatient program (14),psycho-social rehab (17),comm based employ (18),partial prog (12),sheltered workshop/cit (11),social rehab (13)'

          #Booking System Id
          ecolane_profile.system = 'rabbit'
          ecolane_profile.default_trip_purpose = 'Other'
          ecolane_profile.api_version = "8"
          ecolane_profile.booking_counties = primary_coverage_counties
          ecolane_profile.save

        when 'lebanon'

          #Counties
          primary_coverage_counties = ['Lebanon']
          secondary_coverage_counties = ['Lebanon']

          #Funding Sources
          funding_source_array = [['Lottery', 0, false, 'Riders 65 or older'], ['PwD', 1, false, "Riders with disabilities"], ['MATP', 2, false, "Medical Transportation"], ["ADA", 4, false, "Eligible for ADA"], ["Gen Pub", 5, true, "Full Fare"]]

          #Sponsors
          sponsor_array = [['AAA', 1]]

          #Dummy User
          service.fare_user = "79110"

          #Get or create the ecolane_profile
          ecolane_profile = EcolaneProfile.find_or_create_by(service: service)

          #Booking System Id
          ecolane_profile.system= 'lebanon'
          ecolane_profile.api_version = "8"
          ecolane_profile.default_trip_purpose = 'Other'
          ecolane_profile.booking_counties = primary_coverage_counties
          ecolane_profile.save

        when 'cambria'

          #Counties
          primary_coverage_counties = ['Cambria']
          secondary_coverage_counties = ['Cambria']

          #Funding Sources
          funding_source_array = [['Lottery', 0, false, 'Riders 65 or older'], ['PwD', 1, false, "Riders with disabilities"], ["ADA", 3, false, "Eligible for ADA"], ["Gen Pub", 5, true, "Full Fare"]]

          #Sponsors
          sponsor_array = [['MATP', 0],['AAA', 1]]

          #Dummy User
          service.fare_user = "7832"

          #Get or create the ecolane_profile
          ecolane_profile = EcolaneProfile.find_or_create_by(service: service)

          #Optional: Disallowed Trip Purposes
          #this is a comma separated string with no spaces around the commas, and all lower-case
          ecolane_profile.disallowed_purposes_text = 'special approved trips'

          #Booking System Id
          ecolane_profile.system = 'cambria'
          ecolane_profile.api_version = "8"
          ecolane_profile.default_trip_purpose = 'Misc'
          ecolane_profile.booking_counties = primary_coverage_counties
          ecolane_profile.save

        when 'franklin'

          #Counties
          primary_coverage_counties = ['Franklin']
          secondary_coverage_counties = ['Franklin']

          #Funding Sources
          funding_source_array = [['Lottery', 0, false, 'Riders 65 or older'], ['PwD', 1, false, "Riders with disabilities"],['MATP', 2, false, "Medical Transportation"], ["Gen Pub", 5, true, "Full Fare"]]

          #Sponsors
          sponsor_array = [['MATP', 0],['AAA', 1]]

          #Dummy User
          service.fare_user = "2581"

          #Get or create the ecolane_profile
          ecolane_profile = EcolaneProfile.find_or_create_by(service: service)

          #Booking System Id
          ecolane_profile.system = 'rabbit'
          ecolane_profile.api_version = "8"
          ecolane_profile.default_trip_purpose = 'Other'
          ecolane_profile.booking_counties = primary_coverage_counties
          ecolane_profile.save

        when 'dauphin'

          primary_coverage_counties = ['Dauphin']

          #Funding Sources
          funding_source_array = [['Lottery', 0, false, 'Riders 65 or older'], ['PwD', 1, false, "Riders with disabilities"],['MATP', 2, false, "Medical Transportation"], ["ADA", 3, false, "Eligible for ADA"], ["Gen Pub", 5, true, "Full Fare"]]

          #Sponsors
          sponsor_array = [['AAA', 1]]

          #Dummy User
          service.fare_user = "79109"

          ecolane_profile = EcolaneProfile.find_or_create_by(service: service)

          #Optional: Disallowed Trip Purposes
          #this is a comma separated string with no spaces around the commas, and all lower-case
          ecolane_profile.disallowed_purposes_text = 'adult day care,human services,mental health,self determination,sheltered workshop'

          #Booking System Id
          ecolane_profile.system = 'dauphin'
          ecolane_profile.api_version = "8"
          ecolane_profile.default_trip_purpose = 'Medical'
          ecolane_profile.booking_counties = primary_coverage_counties
          ecolane_profile.save

        when 'northumberland'

          primary_coverage_counties = ['Northumberland']
          secondary_coverage_counties = ['Northumberland']

          #Funding Sources
          funding_source_array = [['Lottery', 0, false, 'Riders 65 or older'], ['PWD', 1, false, "Riders with disabilities"], ['MATP', 2, false, "Medical Transportation"], ["Gen Pub", 5, true, "Full Fare"]]

          #Sponsors
          sponsor_array = [['MATP', 0],['NCAAA', 1]]

          #Dummy User
          service.fare_user = "1000004063"

          ecolane_profile = EcolaneProfile.find_or_create_by(service: service)

          #Booking System Id
          ecolane_profile.system = 'northumberland'
          ecolane_profile.api_version = "8"
          ecolane_profile.default_trip_purpose = 'Other'
          ecolane_profile.booking_counties = primary_coverage_counties
          ecolane_profile.save

        when 'unionsnyder'

          #Counties
          primary_coverage_counties = ['Union', 'Snyder']
          secondary_coverage_counties = ['Union', 'Snyder']

          #Funding Sources
          funding_source_array = [['Lottery - US', 0, false, 'Riders 65 or older'], ['PwD-US', 1, false, "Riders with disabilities"], ['MATP - US', 2, false, "Medical Transportation"], ["Gen Public-US", 5, true, "Full Fare"]]

          #Sponsors
          sponsor_array = [['MATP - US', 0],['USAAA', 1]]

          #Dummy User
          service.fare_user = "1000004065"

          #Get or create the ecolane_profile
          ecolane_profile = EcolaneProfile.find_or_create_by(service: service)

          #Booking System Id
          ecolane_profile.system = 'northumberland'
          ecolane_profile.api_version = "8"
          ecolane_profile.default_trip_purpose = 'Medical'
          ecolane_profile.booking_counties = primary_coverage_counties
          ecolane_profile.save

        when 'montour'

          #Counties
          primary_coverage_counties = ['Montour']
          secondary_coverage_counties = ['Montour']

          #Funding Sources
          funding_source_array = [['Lottery-MC', 0, false, 'Riders 65 or older'], ['MATP-MC', 2, false, "Medical Transportation"], ["Gen Pub - MC", 5, true, "Full Fare"]]

          #Sponsors
          sponsor_array = [['MATP-MC', 0],['MCAAA', 1]]

          #Dummy User
          service.fare_user = "1000004064"

          #Get or create the ecolane_profile
          ecolane_profile = EcolaneProfile.find_or_create_by(service: service)

          #Booking System Id
          ecolane_profile.system = 'northumberland'
          ecolane_profile.api_version = "8"
          ecolane_profile.default_trip_purpose = 'Other'
          ecolane_profile.booking_counties = primary_coverage_counties
          ecolane_profile.save

        when 'blair'

          #Counties
          primary_coverage_counties = ['Blair']
          secondary_coverage_counties = ['Blair']

          #Funding Sources
          funding_source_array = [
            ['Lottery', 0, false, 'Riders 65 or older'],
            ['PwD', 1, false, "Riders with disabilities"],
            ['MATP', 2, false, "Medical Transportation"],
            ['Amtran', 3, false, "Eligible for ADA"],
            ['MHMR', 4, false, "Riders under 65"],
            ['PDA Waiver', 5, false, "Eligible for Medicaid"],
            ['Gen Pub', 6, true, "Full Fare"]
          ]

          #Sponsors
          sponsor_array = [
            ['AAA', 0], ['Greystone', 1], ['Blair Rec Com', 2], ['ACNC', 3],
            ['Health South', 4], ['Valley View', 5], ['FGP', 6], ['MATP', 7],
            ['MHMR', 8], ['Amber Terrace', 9], ['PDA Waiver', 10],
            ['Senior LIFE', 11], ['SCP', 12]
          ]

          #Dummy User
          service.fare_user = "18226"

          #CHANGE TO TRUE WHEN THIS GOES LIVE
          service.active = false

          #Get or create the ecolane_profile
          ecolane_profile = EcolaneProfile.find_or_create_by(service: service)

          #Optional: Disallowed Trip Purposes
          #this is a comma separated string with no spaces around the commas, and all lower-case
          ecolane_profile.disallowed_purposes_text = 'ada,no charge bss,trust,lexington for matp'

          #Booking System Id
          ecolane_profile.system = 'blair'
          ecolane_profile.api_version = "8"
          ecolane_profile.default_trip_purpose = 'Other'
          ecolane_profile.booking_counties = primary_coverage_counties
          ecolane_profile.save

        when 'monroe'

          #Counties
          primary_coverage_counties = ['Monroe']
          secondary_coverage_counties = ['Monroe', 'Carbon']

          #Funding Sources
          funding_source_array = [
            ['Lottery', 0, false, 'Riders 65 or older'],
            ['PwD', 1, false, "Riders with disabilities"],
            ['MATP', 2, false, "Medical Transportation"],
            ["ADA", 4, false, "Eligible for ADA"],
            ['Gen Pub', 6, true, "Full Fare"]
          ]

          #Sponsors
          sponsor_array = [["AAA",0]]

          #Dummy User
          service.fare_user = "12152"

          #CHANGE TO TRUE WHEN THIS GOES LIVE (I.E. WHEN THE GEOCODING ISSUE IS RESOLVED)
          service.active = false

          #Get or create the ecolane_profile
          ecolane_profile = EcolaneProfile.find_or_create_by(service: service)

          #Booking System Id
          ecolane_profile.system = 'monroe'
          ecolane_profile.api_version = "8"
          ecolane_profile.default_trip_purpose = 'Other'
          ecolane_profile.booking_counties = primary_coverage_counties
          ecolane_profile.save

        when 'carbon'

          #Counties
          # primary_coverage_counties = []
          primary_coverage_counties = ['Carbon']
          secondary_coverage_counties = ['Carbon']

          #Funding Sources
          funding_source_array = [
            ['Lottery', 0, false, 'Riders 65 or older'],
            ['PwD', 1, false, "Riders with disabilities"],
            ['MATP', 2, false, "Medical Transportation"],
            ['AAA Carbon', 3, false, "AAA Eligible"],
            ["ADA", 4, false, "Eligible for ADA"]
          ]

          #Sponsors
          sponsor_array = [
            ['AAA Carbon', 0],
            ['MATP', 1],
            ['PDA Waiver Carbon', 2]
          ]

          #Dummy User
          service.fare_user = "test4"

          #CHANGE TO TRUE WHEN THIS GOES LIVE
          service.active = true

          #Optional: Disallowed Trip Purposes
          #this is a comma separated string with no spaces around the commas, and all lower-case
          # ecolane_profile.disallowed_purposes_text = 'ma urgent care,day care (16),outpatient program (14),psycho-social rehab (17),comm based employ (18),partial prog (12),sheltered workshop/cit (11),social rehab (13)'

          #Get or create the ecolane_profile
          ecolane_profile = EcolaneProfile.find_or_create_by(service: service)

          #Booking System Id
          ecolane_profile.system = 'carbon'
          ecolane_profile.api_version = "8"
          ecolane_profile.default_trip_purpose = 'Miscellaneous'
          ecolane_profile.booking_counties = primary_coverage_counties
          ecolane_profile.save

        when 'lanta'

          #Counties
          # primary_coverage_counties = []
          primary_coverage_counties = ['Lehigh', 'Northampton']
          secondary_coverage_counties = ['Lehigh', 'Northampton']

          # Lehigh or Northampton?
          if service.name == "Lehigh Shared Ride"

            #Funding Sources - Lehigh
            funding_source_array = [
              ['Lottery', 0, false, 'Riders 65 or older'],
              ['PwD', 1, false, "Riders with disabilities"],
              ['MATP', 2, false, "Medical Transportation"],
              ['AAA Lehigh', 3, false, "AAA Eligible"],
              ["ADA", 4, false, "Eligible for ADA"],
              ["NUR", 5, false, "Eligible for NUR"],
              ["LANtaFlex", 6, false, "Eligible for LANtaFlex"],
              ["LANtaFlex 65 plus", 7, false, "Eligible for LANtaFlex 65 plus"],
              ["BTGFlex", 8, false, "Eligible for BTGFlex"],
              ["BTGFlex 65 plus", 9, false, "Eligible for BTGFlex 65 plus"],
              ["MATP OOC", 10, false, "Eligible for MATP OOC"],
              ["SB Flex", 11, false, "Eligible for SB Flex"],
              ["SB Flex 65+", 12, false, "Eligible for SB Flex 65+"],
              ["MATP OOC CC", 13, false, "Eligible for MATP OOC CC"],
              ["Flex 504", 14, false, "Eligible for Flex 504"],
              ["Flex 504 65+", 15, false, "Eligible for Flex 504 65+"],
              ['Gen Pub', 20, true, "Full Fare"]
            ]

            #Sponsors - Lehigh
            sponsor_array = [
              ['MATP', 0],
              ['PDA Waiver - Lehigh', 1],
              ['MHMR Lehigh', 2],
              ['LANtaFlex', 3],
              ['AAA Lehigh', 4]
            ]

            #Dummy User - Lehigh
            service.fare_user = "72405"

          elsif service.name == "Northampton Shared Ride"

            #Funding Sources - Northampton
            funding_source_array = [
              ['Lottery', 0, false, 'Riders 65 or older'],
              ['PwD', 1, false, "Riders with disabilities"],
              ['MATP', 2, false, "Medical Transportation"],
              ['AAA Northampton', 3, false, "AAA Eligible"],
              ["ADA", 4, false, "Eligible for ADA"],
              ["NUR", 5, false, "Eligible for NUR"],
              ["LANtaFlex", 6, false, "Eligible for LANtaFlex"],
              ["LANtaFlex 65 plus", 7, false, "Eligible for LANtaFlex 65 plus"],
              ["BTGFlex", 8, false, "Eligible for BTGFlex"],
              ["BTGFlex 65 plus", 9, false, "Eligible for BTGFlex 65 plus"],
              ["MATP OOC", 10, false, "Eligible for MATP OOC"],
              ["SB Flex", 11, false, "Eligible for SB Flex"],
              ["SB Flex 65+", 12, false, "Eligible for SB Flex 65+"],
              ["MATP OOC CC", 13, false, "Eligible for MATP OOC CC"],
              ["Flex 504", 14, false, "Eligible for Flex 504"],
              ["Flex 504 65+", 15, false, "Eligible for Flex 504 65+"],
              ['Gen Pub', 20, true, "Full Fare"]
            ]

            #Sponsors - Northampton
            sponsor_array = [
              ['MATP', 0],
              ['PDA Waiver - Northampton', 1],
              ['MHMR Northampton', 2],
              ['LANtaFlex', 3],
              ['AAA Northampton', 4]
            ]

            #Dummy User - Northampton
            service.fare_user = "72406"

          end

          #CHANGE TO TRUE WHEN THIS GOES LIVE
          service.active = true

          #Get or create the ecolane_profile
          ecolane_profile = EcolaneProfile.find_or_create_by(service: service)

          #Booking System Id
          ecolane_profile.system = 'lanta'
          ecolane_profile.api_version = "8"
          ecolane_profile.default_trip_purpose = 'Miscellaneous'
          ecolane_profile.booking_counties = (service.name == "Lehigh Shared Ride" ? ["Lehigh"] : ["Northampton"])
          ecolane_profile.save

        when 'columbia'

          #Counties
          # primary_coverage_counties = []
          primary_coverage_counties = ['Columbia']
          secondary_coverage_counties = ['Columbia']

          #Funding Sources
          funding_source_array = [['Lottery', 0, false, 'Riders 65 or older'], ['PWD', 1, false, "Riders with disabilities"], ['MATP', 2, false, "Medical Transportation"],["Gen Pub", 3, true, "Full Fare"]]

          #Sponsors
          sponsor_array = [['MATP', 0],['CCAAA', 1]]

          #Dummy User
          service.fare_user = "1000004436"

          #CHANGE TO TRUE WHEN THIS GOES LIVE
          service.active = true

          #Get or create the ecolane_profile
          ecolane_profile = EcolaneProfile.find_or_create_by(service: service)

          #Booking System Id
          ecolane_profile.system = 'northumberland'
          ecolane_profile.api_version = "8"
          ecolane_profile.default_trip_purpose = 'Other'
          ecolane_profile.booking_counties = primary_coverage_counties
          ecolane_profile.save


          else
          puts 'Cannot find service with external_id: ' +  external_id
          next
        end

        #Clear and set Funding Sources
        service.funding_sources.destroy_all
        funding_source_array.each do |fs|
          new_funding_source = FundingSource.where(service: service, code: fs[0]).first_or_create
          new_funding_source.index = fs[1]
          new_funding_source.general_public = fs[2]
          new_funding_source.comment = fs[3]
          new_funding_source.save
        end

        #Clear and set Sponsors
        service.sponsors.destroy_all
        sponsor_array.each do |s|
          new_sponsor = Sponsor.where(service: service, code: s[0]).first_or_create
          new_sponsor.index = s[1]
          new_sponsor.save
        end

        #Confirm API Token is set
        if service.ecolane_profile.token.nil?
          puts 'Be sure to setup a token for ' + service.name  + ' ' + external_id + ', service_id = ' + service.id.to_s
          puts 'In console, run: Service.find(<id>).ecolane_profile.update_attributes(token: "<token>") '
        end

        # Build Service Coverage Area Geometries
        service.primary_coverage = CoverageZone.build_coverage_area(primary_coverage_counties)
        service.secondary_coverage = CoverageZone.build_coverage_area(secondary_coverage_counties)

        service.save

      else

      end
    end
  end

  desc "Turn On Test Rabbit and Turn off Real Rabbit"
  task turn_on_test_service: :environment do
    ecolane_service = {name: "Rabbit Shared Ride Test", external_id: "cambridge-test"}

    service_type = ServiceType.find_by(code: "paratransit")

    service = Service.find_or_create_by(service_type: service_type, external_id: ecolane_service[:external_id]) do |service|
      puts 'Creating a new service for ' + ecolane_service.as_json.to_s
      service.service_type = service_type
      service.name = ecolane_service[:name]
      provider = Provider.find_or_create_by(name: ecolane_service[:name])
      service.provider = provider
      service.booking_profile = BookingServices::AGENCY[:ecolane]
      service.save
    end

    #Before running this task:  For each service with ecolane booking, set the Service Id to the lowercase county name
    #and set the Booking Service Code to 'ecolane' These fields are found on the service profile page
    #Counties
    primary_coverage_counties = ['York', 'Adams', 'Cumberland', 'Perry']
    secondary_coverage_counties = ['York', 'Adams', 'Cumberland', 'Dauphin', 'Franklin', 'Lebanon', 'Perry']

    #Funding Sources
    funding_source_array = [['Lottery', 0, false, 'Riders 65 or older'], ['Lottery [21]', 0, false, 'Riders 65 or older'], ['PWD', 1, false, "Riders with disabilities"], ['MATP', 2, false, "Medical Transportation"], ["ADAYORK1", 3, false, "Eligible for ADA"], ["Gen Pub", 5, true, "Full Fare"]]

    #Sponsors
    sponsor_array = [['MATP', 0],['YCAAA', 1]]

    #Dummy User
    service.fare_user = "79109"

    #Get or create the ecolane_profile
    ecolane_profile = EcolaneProfile.find_or_create_by(service: service)

    #Optional: Disallowed Trip Purposes
    #this is a comma separated string with no spaces around the commas, and all lower-case
    ecolane_profile.disallowed_purposes_text = 'ma urgent care,day care (16),outpatient program (14),psycho-social rehab (17),comm based employ (18),partial prog (12),sheltered workshop/cit (11),social rehab (13)'

    #Booking System Id
    ecolane_profile.system = 'cambridge-test'
    ecolane_profile.api_version = "9"
    ecolane_profile.default_trip_purpose = 'Other'
    ecolane_profile.booking_counties = primary_coverage_counties
    ecolane_profile.save

    #Clear and set Funding Sources
    service.funding_sources.destroy_all
    funding_source_array.each do |fs|
      new_funding_source = FundingSource.where(service: service, code: fs[0]).first_or_create
      new_funding_source.index = fs[1]
      new_funding_source.general_public = fs[2]
      new_funding_source.comment = fs[3]
      new_funding_source.save
    end

    #Clear and set Sponsors
    service.sponsors.destroy_all
    sponsor_array.each do |s|
      new_sponsor = Sponsor.where(service: service, code: s[0]).first_or_create
      new_sponsor.index = s[1]
      new_sponsor.save
    end

    #Confirm API Token is set
    if service.ecolane_profile.token.nil?
      puts 'Be sure to setup a token for ' + service.name  + ' ' + service.external_id + ', service_id = ' + service.id.to_s
    end

    # Build Service Coverage Area Geometries
    service.primary_coverage = CoverageZone.build_coverage_area(primary_coverage_counties)
    service.secondary_coverage = CoverageZone.build_coverage_area(secondary_coverage_counties)
    service.active = true

    puts "The Rabbit Test Service has been Turned On"
    service.save

    #### Turn OFF Rabbit Shared Ride
    s = Service.find_by(external_id: "rabbit")
    if s.nil?
      puts 'The Rabbit service does not exist'
    else
      s.active = false
      s.save
      puts 'The Rabbit service has been turned off.'
    end

  end

  desc "Turn Off the Rabbit Test Service and Turn on the Rabbit Shared Ride Service"
  task turn_off_test_service: :environment do
    s = Service.find_by(external_id: "cambridge-test")
    if s.nil?
      puts 'The test service does not exist'
    else
      s.active = false
      s.save
      puts "The test service has been turned off"
    end

    s = Service.find_by(external_id: "rabbit")
    if s.nil?
      puts 'The Rabbit service does not exist'
    else
      s.active = true
      s.save
      puts 'The Rabbit service has been turned on.'
    end

  end

end
