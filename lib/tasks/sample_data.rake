namespace :oneclick do
  desc "Add Sample Data for configured brand."
  task :add_sample_data => :environment do
    case Oneclick::Application.config.brand
      when 'arc'
        puts 'Loading ARC Sample Data...'
        require File.join(Rails.root, 'db', 'arc/arc_sample_data.rb')
      when 'pa'
        puts 'Loading PA Sample Data...'
        require File.join(Rails.root, 'db', 'pa/pa_sample_data.rb')
      when 'broward'
        puts 'Loading Broward Sample Data...'
        require File.join(Rails.root, 'db', 'broward/broward_sample_data.rb')
      when 'jta'
        puts 'Currently no JTA Sample Data...'
        # require File.join(Rails.root, 'db', 'broward/broward_sample_data.rb')
      else
        puts 'UNKNOWN BRAND: ' + Oneclick::Application.config.brand.to_s
        return
    end

    puts 'Running sample data common to all providers...'
    require File.join(Rails.root, 'db', 'common_sample_data.rb')
    puts 'Finished running sample data common to all providers.'

  end

  desc "Update Attributes Per Installation."
  task :update_attributes => :environment do
    require File.join(Rails.root, 'db', Oneclick::Application.config.brand + '/update_attributes.rb')
  end

  desc "Update Origin/Destination to Endpoints/Coverages"
  task :create_endpoints_and_coverages => :environment do
    ServiceCoverageMap.all.each do |scm|
      case scm.rule
      when 'origin'
        scm.rule = 'endpoint_area'
      when  'destination'
        scm.rule = 'coverage_area'
      end
      scm.save
    end

    Service.all.each do  |service|
      service.build_polygons
    end

  end

  desc "Add Cities"
  task :add_cities => :environment do
    cities = []
    case Oneclick::Application.config.brand

      when 'broward'
        cities = ["Cooper City",
                  "Lauderdale Lakes",
                  "Miramar",
                  "Sunrise",
                  "Davie",
                  "Tamarac",
                  "Wilton Manors",
                  "Pompano Beach",
                  "Margate",
                  "Coral Springs",
                  "Coconut Creek",
                  "North Lauderdale",
                  "Lauderhill",
                  "Parkland",
                  "Miami",
                  "Fort Lauderdale",
                  "Miami Beach",
                  "Boca Raton"]
      when 'ieuw'
        cities = ["Nipton","Barstow","Boron","Lancaster","Chino Hills","Chino","Montclair","Pinon Hills","Wrightwood","Phelan","Mira Loma","Corona","Riverside","Ontario","Bloomington","Fontana","Beaumont","Yucaipa","Calimesa","Grand Terrace","Colton","Redlands","Lake Elsinore","Temecula","Aguanga","Ridgecrest","Trona","Blythe","Vidal","Needles","Anza","Thermal","Desert Hot Springs","Joshua Tree","Morongo Valley","Yucca Valley","Baker","Fort Irwin","Cima","Mountain Pass","Apple Valley","Daggett","Lucerne Valley","Oro Grande","Victorville","Adelanto","Helendale","Hinkley","Yermo","Rancho Cucamonga","Upland","Rialto","Hesperia","Lytle Creek","San Bernardino","Mt Baldy","Guasti","Angelus Oaks","Big Bear City","Big Bear Lake","Forest Falls","Fawnskin","Sugarloaf","Loma Linda","Mentone","Highland","Blue Jay","Cedar Glen","Cedarpines Park","Crestline","Green Valley Lake","Lake Arrowhead","Running Springs","Skyforest","Twin Peaks","Red Mountain","Earp","Parker Dam","Essex","Twentynine Palms","Landers","Newberry Springs","Pioneertown","Amboy","Norco","Banning","Cabazon","March Air Reserve Base","Moreno Valley","Perris","Sun City","Wildomar","Winchester","Hemet","Homeland","Idyllwild","Murrieta","Nuevo","San Jacinto","Menifee","Quail Valley","Indio","Cathedral City","Coachella","La Quinta","Mecca","Palm Desert","Palm Springs","Rancho Mirage","Mountain Center","Indian Wells","Desert Center","Thousand Palms","Whitewater","North Palm Springs"]

    end

    cities.each do |city|
      puts city
      GeoCoverage.where(value: city, coverage_type: 'city').first_or_create
    end

  end

  desc "Add ZipCodes"
  task :add_zipcodes => :environment do
    cities = []
    case Oneclick::Application.config.brand

      when 'ieuw'
        zipcodes = ["92364","92311","93516","93535","91709","91710","91763","92372","92397","92371","91752","92880","92509","91761","91762","92316","92337","92223","92399","92320","92507","92313","92324","92373","92530","92883","92592","92536","93555","93562","92225","92280","92363","92539","92274","92241","92252","92256","92284","92309","92310","92323","92366","92307","92327","92356","92368","92394","92395","92301","92342","92347","92392","92398","91701","91737","91784","92377","92336","92344","92358","92407","91759","91708","91730","91739","91764","91786","92376","92335","91743","92305","92314","92315","92339","92333","92386","92354","92359","92374","92401","92408","92410","92411","92308","92346","92404","92405","92345","92317","92321","92322","92325","92341","92352","92382","92385","92391","93558","92242","92267","92332","92277","92278","92285","92365","92268","92304","92860","92879","92882","92501","92506","92503","92504","92505","92881","92220","92230","92508","92518","92551","92553","92555","92557","92571","92585","92595","92596","92532","92543","92544","92545","92548","92549","92562","92563","92567","92582","92583","92584","92570","92586","92587","92590","92591","92203","92234","92236","92253","92254","92260","92264","92270","92561","92201","92210","92211","92239","92240","92262","92276","92282","92258"]

    end

    zipcodes.each do |zipcode|
      puts zipcode
      GeoCoverage.where(value: zipcode, coverage_type: 'zipcode').first_or_create
    end

  end


end
