class EspReader

  DELIMITER='::'

  SERVICE_DICT = Hash.new #Creates a temporary mapping between ServiceId and ServiceRefId
  PROVIDER_DICT = Hash.new #Creates a temporary mapping between ProviderId and Xid
  @esp_providers

  #Providers indices
  @p_name_idx
  @p_contact_idx
  @p_contact_title_idx
  @p_address_idx
  @p_city_idx
  @p_state_idx
  @p_zip_idx
  @p_area_code_idx
  @p_phone_idx
  @p_url_idx
  @p_email_idx

  #Services indices
  @s_id_idx
  @s_ref_id_idx
  @s_name_idx
  @s_contact_idx
  @s_contact_title_idx
  @s_email_idx
  @s_area_code_idx
  @s_phone_idx
  @s_url_idx
  @s_provider_id_idx
  @s_cost_comments_idx
  @s_time_idx

  #Services Config
  @c_info_idx
  @c_id_idx
  @c_cfg_idx
  @c_item_idx

  def assign_provider_indices
    @p_name_idx = @esp_providers.first.index("Name")
    @p_contact_idx = @esp_providers.first.index("Contact")
    @p_contact_title_idx = @esp_providers.first.index("ContactTitle")
    @p_address_idx = @esp_providers.first.index("LocAddress")
    @p_city_idx = @esp_providers.first.index("LocCity")
    @p_state_idx = @esp_providers.first.index("LocState")
    @p_zip_idx = @esp_providers.first.index("LocZipCode")
    @p_area_code_idx = @esp_providers.first.index("AreaCode1")
    @p_phone_idx = @esp_providers.first.index("Phone1")
    @p_url_idx = @esp_providers.first.index("URL")
    @p_email_idx = @esp_providers.first.index("Email")
    @p_provider_id_idx = @esp_providers.first.index("ProviderID")

  end

  def assign_service_indices(services)
    @s_id_idx = services.first.index("ServiceID")
    @s_ref_id_idx = services.first.index("ServiceRefID")
    @s_name_idx = services.first.index("OrgName")
    @s_contact_idx = services.first.index("Contact")
    @s_contact_title_idx = services.first.index("ContactTitle")
    @s_email_idx = services.first.index("Email")
    @s_area_code_idx = services.first.index("AreaCode1")
    @s_phone_idx = services.first.index("Phone1")
    @s_url_idx = services.first.index("URL")
    @s_provider_id_idx = services.first.index("ProviderID")
    @s_cost_comments_idx = services.first.index("CostComments")
    @s_time_idx = services.first.index("TimeSun1")

  end

  def assign_config_indices(configs)
    @c_info_idx = configs.first.index("InfoID")
    @c_id_idx = configs.first.index("ServiceID")
    @c_cfg_idx = configs.first.index("Grp")
    @c_item_idx = configs.first.index("Item")
  end

  def run
    table = {}
    ["tProvider", "tProviderGrid", "tService", "tServiceGrid", "tServiceCfg", "tServiceCost"].each do |t|
      tempfile = Tempfile.new("#{t}.csv")
      begin
        # TODO input MDB file needs to be parameterized
        p tempfile.path
        `mdb-export -R '||' -b raw db/arc/trans22714.MDB #{t} | dos2unix > #{tempfile.path}`
        table[t] = to_csv tempfile
      ensure
        tempfile.close
        #tempfile.unlink

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

  def unpack_to_table(tempfilepath)
    table = {}
    ["tProvider", "tProviderGrid", "tService", "tServiceGrid", "tServiceCfg", "tServiceCost"].each do |t|
      tempfile = Tempfile.new("#{t}.csv")
      #tempfile = Tempfilenew(tempfilepath)
      begin
        # TODO input MDB file needs to be parameterized
        #tempfilepath = 'db/arc/trans22714.MDB'
        p tempfile.path
        #`mdb-export -R '||' -b raw ` + tempfilepath + ` #{t} | dos2unix > #{tempfile.path}`
        system "mdb-export -R '||' -b raw " + tempfilepath + " #{t} | dos2unix > #{tempfile.path}"
        table[t] = to_csv tempfile
      ensure
        tempfile.close
        #tempfile.unlink

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
      if provider_id == esp_provider[@p_provider_id_idx]
        return esp_provider
      end
    end
    nil
  end

  # This is the main function.
  # It unpacks the esp data and stores it in the OneClick format
  def unpack(tempfilepath)
    entries = self.unpack_to_table(tempfilepath)

    #Pull out the Esp Providers
    @esp_providers = entries['tProvider']
    #Find the indices of the important columns
    assign_provider_indices

    #Create or update services
    esp_services = entries['tService']
    assign_service_indices(esp_services)
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
    assign_config_indices(esp_configs)
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

    provider.name = esp_provider[@p_name_idx]
    provider.contact = esp_provider[@p_contact_idx]
    provider.contact_title = esp_provider[@p_contact_title_idx]
    provider.address = esp_provider[@p_address_idx]
    provider.city = esp_provider[@p_city_idx]
    provider.state = esp_provider[@p_state_idx]
    provider.zip = esp_provider[@p_zip_idx]
    provider.phone = '(' + esp_provider[@p_area_code_idx].to_s + ') ' + esp_provider[@p_phone_idx].to_s
    provider.url = esp_provider[@p_url_idx]
    provider.email = esp_provider[@p_email_idx]
    provider.save

    if create #assign service to the new provider
      service.provider = provider
      service.service_type = ServiceType.find_by_code('paratransit')
      service.save
    end
  end

  def create_or_update_services esp_services
    services = []
    esp_services.each do |esp_service|

      SERVICE_DICT[esp_service[@s_id_idx]] = esp_service[@s_ref_id_idx]
      service = Service.where(external_id: esp_service[@s_ref_id_idx]).first_or_initialize
      service.name = esp_service[@s_name_idx]
      service.contact = esp_service[@s_contact_idx]
      service.contact_title = esp_service[@s_contact_title_idx]
      service.email = esp_service[@s_email_idx]
      service.phone = '(' + esp_service[@s_area_code_idx].to_s + ') ' + esp_service[@s_phone_idx].to_s
      service.url = esp_service[@s_url_idx]

      service.service_type = ServiceType.find_by_code('paratransit')
      service.advanced_notice_minutes = 0  #TODO: Need to get this from ESP
      service.active = true
      esp_provider = get_esp_provider(esp_service[@s_provider_id_idx])

      create_or_update_provider(esp_provider, service, service.provider.nil?)
      service.save

      #Clean up this service
      service.schedules.destroy_all
      service.service_coverage_maps.destroy_all
      service.service_accommodations.destroy_all
      service.service_characteristics.destroy_all
      service.service_trip_purpose_maps.destroy_all
      service.fare_structures.destroy_all
      #Add Curb to Curb by default
      accommodation = Accommodation.find_by_code('curb_to_curb')
      ServiceAccommodation.create(service: service, accommodation: accommodation, value: 'true')

      #Set new schedule
      (0..6).each do |day|
        index = @s_time_idx + 2*day
        if esp_service[index] and esp_service[index+1]
          Schedule.create(service: service, start_seconds: Time.parse(esp_service[index][9..16]).seconds_since_midnight, end_seconds: Time.parse(esp_service[index+1][9..16]).seconds_since_midnight, day_of_week: day)
        end
      end

      #Set Cost Comments
      FareStructure.create(service: service, fare_type: 2, desc: esp_service[@s_cost_comments_idx])

      #TODO: Purposes
      #Purposes will be listed ast tServiceCfg CfgNum = 5.  The sample data did not include any purpose examples.
      services << service
    end

    services
  end

  def create_or_update_eligibility esp_configs
    esp_configs.each do |config|
      service = Service.find_by_external_id(SERVICE_DICT[config[@c_id_idx]])

      case config[@c_cfg_idx].to_i
        when 1,2
          add_accommodation(service, config[@c_item_idx])
        when 5
          add_eligibility(service, config[@c_item_idx])
        when 6 #ZipCode Restriction
          c = GeoCoverage.find_or_create_by_value(value: config[@c_item_idx], coverage_type: 'zipcode')
          ServiceCoverageMap.find_or_create_by_service_id_and_geo_coverage_id_and_rule(service_id: service.id, geo_coverage_id: c.id, rule: 'destination')
          ServiceCoverageMap.find_or_create_by_service_id_and_geo_coverage_id_and_rule(service_id: service.id, geo_coverage_id: c.id, rule: 'origin')
      end
    end
  end

  def create_or_update_coverages esp_configs
    esp_configs.each do |config|
      service = Service.find_by_external_id(SERVICE_DICT[config[1]])
      case config[@c_cfg_idx].downcase
        when 'county'
          c = GeoCoverage.find_or_create_by_value(value: config[@c_item_idx], coverage_type: 'county_name')
          ServiceCoverageMap.find_or_create_by_service_id_and_geo_coverage_id_and_rule(service_id: service.id, geo_coverage_id: c.id, rule: 'destination')
          ServiceCoverageMap.find_or_create_by_service_id_and_geo_coverage_id_and_rule(service_id: service.id, geo_coverage_id: c.id, rule: 'origin')
      end
    end
  end

  def create_or_update_fares esp_configs
    esp_configs.each do |config|
      service = Service.find_by_external_id(SERVICE_DICT[config[1]])
      fare = FareStructure.find_by_service_id(service.id)
      case config[@c_cfg_idx].downcase
        when 'transportation'
          amount = config[@c_item_idx].to_f
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
      when 'companion allowed', 'escort allowed'
        accommodation = Accommodation.find_by_code('companion_allowed')
      when 'curb to curb'
        accommodation = Accommodation.find_by_code('curb_to_curb')
      when 'stretchers'
        accommodation = Accommodation.find_by_code('stretcher_accessible')
      when 'ground', 'volunteer services'
        return
      else
        raise "ACCOMMODATION NOT FOUND:  " + accommodation.to_s
    end
    ServiceAccommodation.find_or_create_by(service: service, accommodation: accommodation, value: 'true')
  end

  def add_eligibility(service, eligibility)
    #Give all rules in this eligibility the same group.
    group = (service.service_characteristics.pluck(:group).max || -1) + 1
    rules = eligibility.split(' and ')
    rules.each do |rule|
      if rule[0..2].downcase == 'age'
        characteristic = Characteristic.find_by_code('age')
        ServiceCharacteristic.create(service: service, characteristic: characteristic, value: rule.gsub(/[^0-9]/, ''), value_relationship_id: 4, group: group)
        next
      end

      case rule.downcase
        when 'disabled'
          characteristic = Characteristic.find_by_code('disabled')
          ServiceCharacteristic.create(service: service, characteristic: characteristic, value: true, group: group)
        when 'disabled veteran'
          characteristic = Characteristic.find_by_code('disabled')
          ServiceCharacteristic.create(service: service, characteristic: characteristic, value: true, group: group)
          characteristic = Characteristic.find_by_code('veteran')
          ServiceCharacteristic.create(service: service, characteristic: characteristic, value: true, group: group)
        when 'county resident'
          # When county resident is required.  The person must also be a resident of the county in addition to traveling within that county.
          # The coverages were created previously.
          service.coverage_areas.where(:coverage_type => "county_name").map(&:value).uniq.each do |county_name|
            c = GeoCoverage.find_or_create_by_value(value: county_name, coverage_type: 'county_name')
            ServiceCoverageMap.find_or_create_by_service_id_and_geo_coverage_id_and_rule(service_id: service.id, geo_coverage_id: c.id, rule: 'residence')
          end
        when 'military/veteran'
          characteristic = Characteristic.find_by_code('veteran')
          ServiceCharacteristic.create(service: service, characteristic: characteristic, value: true, group: group)
        when 'medical purposes only'
          medical = TripPurpose.find_by_code('medical')
          ServiceTripPurposeMap.create(service: service, trip_purpose: medical, value: 'true')
        when 'no restrictions'
          return
        else
          raise "ELIGIBILITY RULE NOT FOUND:  " + rule.to_s
      end

    end
  end

end
