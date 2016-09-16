
namespace :oneclick do

  desc "Ecolane Help"
  task ecolane_help: :environment do
    puts "Don't forget to change external_id of york to rabbit"
    puts "run rake oneclick:create_api_guest to create the designated guest for api users (prevents thousands of new guests from being created"
    puts "run rake oneclick:create_ecolane_services to create the services."
    puts "After that, run rake oneclick:setup_ecolane_services to setup the ecolane funding sources/sponsors, test users, etc."
    puts "After that you will need to manually add the tokens. A list of services that need tokens will be printed."
    puts "FYI: It's ok to run any of these commands multiple times.  They are idempotent."
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
      {name: "Shared Ride", external_id: "blair"}
    ]

    puts ecolane_services.ai

    service_type = ServiceType.find_by(code: "paratransit")

    ecolane_services.each do |ecolane_service|
      service = Service.find_or_create_by(service_type: service_type, external_id: ecolane_service[:external_id]) do |service|
        puts 'Creating a new service for ' + ecolane_service.as_json.to_s
        service.service_type = service_type
        service.name = ecolane_service[:name]
        provider = Provider.find_or_create_by(name: ecolane_service[:name])
        service.provider = provider
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

      if service
        external_id = service.external_id
        puts 'Setting up ' + ( service.name || service.id.to_s ) + ' for ' +  external_id

        case external_id
        when 'rabbit'

          #Counties
          service.county_endpoint_array = ['York', 'Adams', 'Cumberland']
          service.county_coverage_array = ['York', 'Adams', 'Cumberland', 'Dauphin', 'Franklin', 'Lebanon']

          #Funding Sources
          funding_source_array = [['Lottery', 0, false, 'Riders 65 or older'], ['Lottery [21]', 0, false, 'Riders 65 or older'], ['PWD', 1, false, "Riders with disabilities"], ['MATP', 2, false, "Medical Transportation"], ["ADAYORK1", 3, false, "Eligible for ADA"], ["Gen Pub", 5, true, "Full Fare"]]

          #Sponsors
          sponsor_array = [['MATP', 0],['YCAAA', 1]]

          #Dummy User
          service.fare_user = "79109"

          #Optional: Disallowed Trip Purposes
          #this is a comma separated string with no spaces around the commas, and all lower-case
          service.disallowed_purposes = 'ma urgent care,day care (16),outpatient program (14),psycho-social rehab (17),comm based employ (18),partial prog (12),sheltered workshop/cit (11),social rehab (13)'

          #Get or create the ecolane_profile
          ecolane_profile = EcolaneProfile.find_or_create_by(service: service)

          #Booking System Id
          ecolane_profile.system = 'rabbit'
          ecolane_profile.default_trip_purpose = 'Other'
          ecolane_profile.save

        when 'lebanon'

          #Counties
          service.county_endpoint_array = ['Lebanon']
          service.county_coverage_array = ['Lebanon']

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
          ecolane_profile.default_trip_purpose = 'Other'
          ecolane_profile.save


        when 'cambria'

          #Counties
          service.county_endpoint_array = ['Cambria']
          service.county_coverage_array = ['Cambria']

          #Funding Sources
          funding_source_array = [['Lottery', 0, false, 'Riders 65 or older'], ['PwD', 1, false, "Riders with disabilities"], ["ADA", 3, false, "Eligible for ADA"], ["Gen Pub", 5, true, "Full Fare"]]

          #Sponsors
          sponsor_array = [['MATP', 0],['AAA', 1]]

          #Dummy User
          service.fare_user = "7832"

          #Optional: Disallowed Trip Purposes
          #this is a comma separated string with no spaces around the commas, and all lower-case
          service.disallowed_purposes = 'special approved trips'

          #Get or create the ecolane_profile
          ecolane_profile = EcolaneProfile.find_or_create_by(service: service)

          #Booking System Id
          ecolane_profile.system = 'cambria'
          ecolane_profile.default_trip_purpose = 'Misc'
          ecolane_profile.save


        when 'franklin'

          #Counties
          service.county_endpoint_array = ['Franklin']
          service.county_coverage_array = ['Franklin']

          #Funding Sources
          funding_source_array = [['Lottery', 0, false, 'Riders 65 or older'], ['PwD', 1, false, "Riders with disabilities"],['MATP', 2, false, "Medical Transportation"], ["Gen Pub", 5, true, "Full Fare"]]

          #Sponsors
          sponsor_array = [['MATP', 0],['AAA', 1]]

          #Dummy User
          service.fare_user = "2581"

          #Get or create the ecolane_profile
          ecolane_profile = EcolaneProfile.find_or_create_by(service: service)

          #Booking System Id
          ecolane_profile.system = 'franklin'
          ecolane_profile.default_trip_purpose = 'Other'
          ecolane_profile.save



        when 'dauphin'

          service.county_endpoint_array = ['Dauphin']

          #Funding Sources
          funding_source_array = [['Lottery', 0, false, 'Riders 65 or older'], ['PwD', 1, false, "Riders with disabilities"],['MATP', 2, false, "Medical Transportation"], ["ADA", 3, false, "Eligible for ADA"], ["Gen Pub", 5, true, "Full Fare"]]

          #Sponsors
          sponsor_array = [['AAA', 1]]

          #Dummy User
          service.fare_user = "79109"

          #Optional: Disallowed Trip Purposes
          #this is a comma separated string with no spaces around the commas, and all lower-case
          service.disallowed_purposes = 'adult day care,human services,mental health,self determination,sheltered workshop'

          ecolane_profile = EcolaneProfile.find_or_create_by(service: service)

          #Booking System Id
          ecolane_profile.system = 'dauphin'
          ecolane_profile.default_trip_purpose = 'Medical'
          ecolane_profile.save

        when 'northumberland'

          service.county_endpoint_array = ['Northumberland']
          service.county_coverage_array = ['Northumberland']

          #Funding Sources
          funding_source_array = [['Lottery', 0, false, 'Riders 65 or older'], ['PWD', 1, false, "Riders with disabilities"], ['MATP', 2, false, "Medical Transportation"], ["Gen Pub", 5, true, "Full Fare"]]

          #Sponsors
          sponsor_array = [['MATP', 0],['NCAAA', 1]]

          #Dummy User
          service.fare_user = "1000004063"

          #Optional: Disallowed Trip Purposes
          #this is a comma separated string with no spaces around the commas, and all lower-case
          #service.disallowed_purposes = 'special approved trips'

          ecolane_profile = EcolaneProfile.find_or_create_by(service: service)

          #Booking System Id
          ecolane_profile.system = 'northumberland'
          ecolane_profile.default_trip_purpose = 'Other'
          ecolane_profile.save

        when 'unionsnyder'

          #Counties
          service.county_endpoint_array = ['Union', 'Snyder']
          service.county_coverage_array = ['Union', 'Snyder']

          #Funding Sources
          funding_source_array = [['Lottery - US', 0, false, 'Riders 65 or older'], ['PwD-US', 1, false, "Riders with disabilities"], ['MATP - US', 2, false, "Medical Transportation"], ["Gen Public-US", 5, true, "Full Fare"]]

          #Sponsors
          sponsor_array = [['MATP - US', 0],['USAAA', 1]]

          #Dummy User
          service.fare_user = "1000004065"

          #Optional: Disallowed Trip Purposes
          #this is a comma separated string with no spaces around the commas, and all lower-case
          #service.disallowed_purposes = 'number1,number2'

          #Get or create the ecolane_profile
          ecolane_profile = EcolaneProfile.find_or_create_by(service: service)

          #Booking System Id
          ecolane_profile.system = 'northumberland'
          ecolane_profile.default_trip_purpose = 'Medical'
          ecolane_profile.save

        when 'montour'

          #Counties
          service.county_endpoint_array = ['Montour']
          service.county_coverage_array = ['Montour']

          #Funding Sources
          funding_source_array = [['Lottery-MC', 0, false, 'Riders 65 or older'], ['MATP-MC', 2, false, "Medical Transportation"], ["Gen Pub - MC", 5, true, "Full Fare"]]

          #Sponsors
          sponsor_array = [['MATP-MC', 0],['MCAAA', 1]]

          #Dummy User
          service.fare_user = "1000004064"

          #Optional: Disallowed Trip Purposes
          #this is a comma separated string with no spaces around the commas, and all lower-case
          #service.disallowed_purposes = 'number1,number2'

          #Get or create the ecolane_profile
          ecolane_profile = EcolaneProfile.find_or_create_by(service: service)

          #Booking System Id
          ecolane_profile.system = 'northumberland'
          ecolane_profile.default_trip_purpose = 'Other'
          ecolane_profile.save

        when 'blair'

          #Counties
          service.county_endpoint_array = ['Blair']
          service.county_coverage_array = ['Blair']

          #Funding Sources
          funding_source_array = [
            ['Lottery', 0, false, 'Riders 65 or older']
          ]

          #Sponsors
          sponsor_array = [['AAA', 0]]

          #Dummy User
          service.fare_user = "14411"

          #Optional: Disallowed Trip Purposes
          #this is a comma separated string with no spaces around the commas, and all lower-case
          # service.disallowed_purposes = 'ma urgent care,day care (16),outpatient program (14),psycho-social rehab (17),comm based employ (18),partial prog (12),sheltered workshop/cit (11),social rehab (13)'

          #Get or create the ecolane_profile
          ecolane_profile = EcolaneProfile.find_or_create_by(service: service)

          #Booking System Id
          ecolane_profile.system = 'blair'
          ecolane_profile.default_trip_purpose = 'Other'
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
        end

        service.save

      else

      end
    end
   end
end
