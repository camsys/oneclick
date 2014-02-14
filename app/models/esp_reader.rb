class EspReader

  DELIMITER='::'

  SERVICE_DICT = Hash.new #Creates a temporary mapping between ServiceId and ServiceRefId
  PROVIDER_DICT = Hash.new #Creates a temporary mapping between ProviderId and Xid
  @esp_providers

  def run
    table = {}
    ["tProvider", "tProviderGrid", "tService", "tServiceGrid", "tServiceCfg", "tServiceCost"].each do |t|
      tempfile = Tempfile.new("#{t}.csv")
      begin
        # TODO input MDB file needs to be parameterized
        `mdb-export -R '||' -b raw db/arc/melton_esptest1222013.MDB #{t} | dos2unix > #{tempfile.path}`
        table[t] = to_csv tempfile
      ensure
        tempfile.close
        tempfile.unlink

      end
    end
    table
  end

  def run_zip(tempfilepath)
    table = {}
    require 'zip'
    Zip::File.open(tempfilepath) do |zipfile|
      zipfile.each do |file|
        table[file.name[0..-5]] = to_csv file.get_input_stream
      end
    end
    table
  end

  def slurp file
    whole_file = file.read
    whole_file.split '||'
  end

  def to_csv file
    slurp(file).collect do |row|
      CSV.parse(row).flatten
    end
  end

  def get_esp_provider provider_id
    @esp_providers.each do |esp_provider|
      if provider_id == esp_provider[0]
        return esp_provider
      end
    end
    nil
  end

  # This is the main function.
  # It unpacks the esp data and stores it in the OneClick format
  def unpack(tempfilepath)
    entries = self.run_zip(tempfilepath)

    #Pull out the Esp Providers
    @esp_providers = entries['tProvider']

    #Create or update services
    esp_services = entries['tService']
    esp_services.shift #deletes header row
    services = create_or_update_services(esp_services)

    #deactive services that are not included in the list
    all_services = Service.all

    all_services.each do |s|
      unless s.in? services
        s.active = false
        s.save
      end
    end

    #Add County Coverage Rules
    esp_configs = entries['tServiceGrid']
    esp_configs.shift
    create_or_update_coverages(esp_configs)

    #Add Eligibility
    esp_configs = entries['tServiceCfg']
    esp_configs.shift
    create_or_update_eligibility(esp_configs)

    #Add Fares
    esp_configs = entries['tServiceCost']
    esp_configs.shift
    create_or_update_fares(esp_configs)

  end

  def create_or_update_provider esp_provider, service, create = false
    if create
      provider = Provider.new
    else
      provider = service.provider
    end

    provider.name = esp_provider[1]
    provider.contact = esp_provider[3]
    provider.contact_title = esp_provider[4]
    provider.address = esp_provider[5]
    provider.city = esp_provider[6]
    provider.state = esp_provider[7]
    provider.zip = esp_provider[8]
    provider.phone = '(' + esp_provider[16].to_s + ') ' + esp_provider[17].to_s
    provider.url = esp_provider[24]
    provider.email = esp_provider[23]
    provider.save

    if create #assign service to the new provider
      service.provider = provider
      service.save
    end
  end

  def create_or_update_services esp_services
    services = []
    esp_services.each do |esp_service|
      SERVICE_DICT[esp_service[0]] = esp_service[73]
      service = Service.find_or_initialize_by_external_id(esp_service[73])
      service.name = esp_service[1]
      service.contact = esp_service[4]
      service.contact_title = esp_service[5]
      service.email = esp_service[28]
      service.phone = '(' + esp_service[21].to_s + ') ' + esp_service[22].to_s
      service.url = esp_service[29]

      service.service_type = ServiceType.find_by_name('Paratransit')
      service.advanced_notice_minutes = 0  #TODO: Need to get this from ESP
      service.active = true
      esp_provider = get_esp_provider(esp_service[2])

      create_or_update_provider(esp_provider, service, service.provider.nil?)
      service.save

      #Clean up this service
      service.schedules.destroy_all
      service.service_coverage_maps.destroy_all
      service.traveler_accommodations.destroy_all
      service.traveler_characteristics.destroy_all
      service.service_trip_purpose_maps.destroy_all
      service.fare_structures.destroy_all
      #Add Curb to Curb by default
      accommodation = Accommodation.find_by_code('curb_to_curb')
      ServiceTravelerAccommodationsMap.create(service: service, traveler_accommodation: accommodation, value: 'true')

      #Set new schedule
      (0..6).each do |day|
        index = 43 + 2*day
        if esp_service[index] and esp_service[index+1]
          Schedule.create(service: service, start_time: esp_service[index], end_time: esp_service[index+1], day_of_week: day)
        end
      end

      #Set Cost Comments
      FareStructure.create(service: service, fare_type: 2, desc: esp_service[70])

      #TODO: Purposes
      #Purposes will be listed ast tServiceCfg CfgNum = 5.  The sample data did not include any purpose examples.
      services << service
    end

    services
  end

  def create_or_update_eligibility esp_configs
    esp_configs.each do |config|
      service = Service.find_by_external_id(SERVICE_DICT[config[1]])

      case config[2].to_i
        when 1,2
          add_accommodation(service, config[3])
        when 5
          add_eligibility(service, config[3])
        when 6 #ZipCode Restriction
          c = GeoCoverage.find_or_create_by_value(value: config[3], coverage_type: 'zipcode')
          ServiceCoverageMap.find_or_create_by_service_id_and_geo_coverage_id_and_rule(service_id: service.id, geo_coverage_id: c.id, rule: 'destination')
          ServiceCoverageMap.find_or_create_by_service_id_and_geo_coverage_id_and_rule(service_id: service.id, geo_coverage_id: c.id, rule: 'origin')
      end
    end
  end

  def create_or_update_coverages esp_configs
    esp_configs.each do |config|
      service = Service.find_by_external_id(SERVICE_DICT[config[1]])
      case config[2].downcase
        when 'county'
          c = GeoCoverage.find_or_create_by_value(value: config[3], coverage_type: 'county_name')
          ServiceCoverageMap.find_or_create_by_service_id_and_geo_coverage_id_and_rule(service_id: service.id, geo_coverage_id: c.id, rule: 'destination')
          ServiceCoverageMap.find_or_create_by_service_id_and_geo_coverage_id_and_rule(service_id: service.id, geo_coverage_id: c.id, rule: 'origin')
      end
    end
  end

  def create_or_update_fares esp_configs
    esp_configs.each do |config|
      service = Service.find_by_external_id(SERVICE_DICT[config[1]])
      fare = FareStructure.find_by_service_id(service.id)
      case config[2].downcase
        when 'transportation'
          amount = config[3].to_f
          if amount >= fare.base.to_f
            fare.base = amount
            fare.fare_type = 0
            fare.save
          end
      end
    end
  end

  def add_accommodation(service, accommodation)
    case accommodation.downcase
      when 'wheelchair lift'
        accommodation = Accommodation.find_by_code('lift_equipped')
      when 'wheelchair/fold'
        accommodation = Accommodation.find_by_code('folding_wheelchair_accessible')
      when 'wheelchair/ motor'
        accommodation = Accommodation.find_by_code('motorized_wheelchair_accessible')
      when 'door to door'
        accommodation = Accommodation.find_by_code('door_to_door')
      when 'driver assistance'
        accommodation = Accommodation.find_by_code('driver_assistance_available')
      when 'companion allowed'
        accommodation = Accommodation.find_by_code('companion_allowed')
      when 'ground', 'volunteer services'
        return
      else
        raise "ACCOMMODATION NOT FOUND:  " + accommodation.to_s
    end
    ServiceTravelerAccommodationsMap.create(service: service, traveler_accommodation: accommodation, value: 'true')
  end

  def add_eligibility(service, eligibility)
    #Give all rules in this eligibility the same group.
    group = (service.service_traveler_characteristics_maps.pluck(:group).max || -1) + 1
    rules = eligibility.split(' and ')
    rules.each do |rule|
      if rule[0..2].downcase == 'age'
        characteristic = Characteristic.find_by_code('age')
        ServiceTravelerCharacteristicsMap.create(service: service, traveler_characteristic: characteristic, value: rule.gsub(/[^0-9]/, ''), value_relationship_id: 4, group: group)
        next
      end

      case rule.downcase
        when 'disabled'
          characteristic = Characteristic.find_by_code('disabled')
          ServiceTravelerCharacteristicsMap.create(service: service, traveler_characteristic: characteristic, value: true, group: group)
        when 'disabled veteran'
          characteristic = Characteristic.find_by_code('disabled')
          ServiceTravelerCharacteristicsMap.create(service: service, traveler_characteristic: characteristic, value: true, group: group)
          characteristic = Characteristic.find_by_code('veteran')
          ServiceTravelerCharacteristicsMap.create(service: service, traveler_characteristic: characteristic, value: true, group: group)
        when 'county resident'
          # When county resident is required.  The person must also be a resident of the county in addition to traveling within that county.
          # The coverages were created previously.
          service.coverage_areas.where(:coverage_type => "county_name").map(&:value).uniq.each do |county_name|
            c = GeoCoverage.find_or_create_by_value(value: county_name, coverage_type: 'county_name')
            ServiceCoverageMap.find_or_create_by_service_id_and_geo_coverage_id_and_rule(service_id: service.id, geo_coverage_id: c.id, rule: 'residence')
          end
        when 'military/veteran'
          characteristic = Characteristic.find_by_code('veteran')
          ServiceTravelerCharacteristicsMap.create(service: service, traveler_characteristic: characteristic, value: true, group: group)
        else
          raise "ELIGIBILITY RULE NOT FOUND:  " + rule.to_s
      end

    end
  end

end
