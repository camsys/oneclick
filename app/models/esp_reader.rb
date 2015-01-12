class EspReader
  require 'zip'
  include ActionView::Helpers::NumberHelper

  DELIMITER='::'

  SERVICE_DICT = Hash.new #Creates a temporary mapping between ServiceId and ServiceRefId
  PROVIDER_DICT = Hash.new #Creates a temporary mapping between ProviderId and Xid
  @esp_providers

  ########################
  # Find indices of relevant columns
  ########################
  def assign_provider_indices
    @provider_idx = {}
    ['Name', 'Contact', 'ContactTitle', 'LocAddress', 'LocCity', 'LocState', 'LocZipCode', 'AreaCode1', 'Phone1', 'URL', 'Email', 'ProviderID', 'Comments'].each do |column_name|
      @provider_idx[column_name] = @esp_providers.first.index(column_name)
      if @provider_idx[column_name].nil?
        return false, 'Missing column ' + column_name + ' from tProvider table.'
      end
    end
    return true, "Success"
  end

  def assign_service_indices(services)
    @service_idx = {}
    ['ServiceID', 'ServiceRefID', 'OrgName', 'Contact', 'ContactTitle', 'Email', 'AreaCode1', 'Phone1', 'URL', 'ProviderID', 'CostComments', 'TimeSun1', 'Comments', 'LocalComments'].each do |column_name|
      @service_idx[column_name] = services.first.index(column_name)
      if @service_idx[column_name].nil?
        return false, 'Missing column ' + column_name + ' from tService table.'
      end
    end
    return true, "Success"
  end

  def assign_config_indices(configs)
    @config_idx = {}
    ['ServiceID', 'CfgNum', 'Item'].each do |column_name|
      @config_idx[column_name] = configs.first.index(column_name)
      if @config_idx[column_name].nil?
        return false, 'Missing column ' + column_name + ' from tServiceCfg'
      end
    end
    return true, "Success"
  end

  def assign_cost_indices(costs)
    @costs_idx = {}
    ['ServiceID', 'CostType', 'Amount', 'CostUnit'].each do |column_name|
      @costs_idx[column_name] = costs.first.index(column_name)
      if @costs_idx[column_name].nil?
        return false, 'Missing column ' + column_name + ' from tServiceCost'
      end
    end
    return true, "Success"
  end

  def assign_grid_indices(grids)
    @grid_idx = {}
    ['ServiceID', 'Grp', 'Item'].each do |column_name|
      @grid_idx[column_name] = grids.first.index(column_name)
      if @grid_idx[column_name].nil?
        return false, 'Missing column ' + column_name + ' from tServiceGrid'
      end
    end
    return true, "Success"
  end
  #end add indices
  ########################

  TABLES = ["tProvider", "tProviderGrid", "tService", "tServiceGrid", "tServiceCfg", "tServiceCost"]

  ########################
  # File Extraction
  ########################
  def unpack_to_tables(tempfilepath)
    unpack_to_csvs(tempfilepath).map do |t, file_info|
      tempfile = file_info[0]
      csv = to_csv tempfile
      tempfile.close
      tempfile.unlink
      [t, csv]
    end.to_h
  end

  def unpack_from_zip_to_tables(tempfilepath)
    Zip::File.open(tempfilepath) do |zipfile|
      zipfile.collect do |entry|
        table_name = File.basename(entry.name, ".csv")
        csv = to_csv(entry.get_input_stream)
        [table_name, csv]
      end.to_h
    end
  end

  def unpack_to_csvs(tempfilepath)
    TABLES.inject({}) do |m, t|
      basename = "#{t}.csv"
      tempfile = Tempfile.new(basename)
      system "mdb-export -R '||' -b raw " + tempfilepath + " #{t} | dos2unix > #{tempfile.path}"
      m[t] = [tempfile, basename]
      m
    end
  end

  def unpack_and_zip(tempfilepath)
    Zip::File.open('esp-csvs.zip', Zip::File::CREATE) do |zipfile|
      unpack_to_csvs(tempfilepath).values.each do |file_info|
        # Two arguments:
        # - The name of the file as it will appear in the archive
        # - The original file, including the path to find it
        zipfile.add(file_info[1], file_info[0])
      end
    end
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
      if provider_id == esp_provider[@provider_idx["ProviderID"]]
        return esp_provider
      end
    end
    nil
  end
  # End File Extraction
  ########################

  #########################
  # This is the main function.
  # It unpacks the esp data and stores it in the OneClick format
  #########################
  def unpack(tempfilepath, filetype)
    Rails.logger.info "EspReader: unpack"
    case filetype
    when :mdb
      entries = self.unpack_to_tables(tempfilepath)
    when :csvzip
      entries = self.unpack_from_zip_to_tables(tempfilepath)
    end

    ###########
    ## Go through each table and confirm that we have all the columns needed to build the data
    ###########

    Rails.logger.info "EspReader: check columns"
    #Confirm tProvider has necessary columns
    @esp_providers = entries['tProvider']
    #Find the indices of the important columns
    if @esp_providers.nil? || @esp_providers.empty?
      return false, "tProvider table is missing or invalid."
    end
    result, message = assign_provider_indices
    unless result
      return result, message
    end

    #Confirm tService has necessary columns
    esp_services = entries['tService']
    if esp_services.nil? || esp_services.empty?
      return false, "tService table is missing or invalid."
    end
    result, message = assign_service_indices(esp_services)
    unless result
      return result, message
    end

    #Confirm tServiceGrid has necessary columns
    esp_grids = entries['tServiceGrid']
    if esp_grids.nil? || esp_grids.empty?
      return false, "tServiceGrid is missing or invalid."
    end
    result, message = assign_grid_indices(esp_grids)
    unless result
      return result, message
    end

    esp_configs = entries['tServiceCfg']
    if esp_configs.nil? || esp_configs.empty?
      return false, "tServiceCfg is missing or invalid."
    end
    result, message = assign_config_indices(esp_configs)
    unless result
      return result, message
    end

    esp_costs = entries['tServiceCost']
    if esp_costs.nil? || esp_configs.empty?
      return false, "tServiecCost is missing or invalid."
    end
    result, message = assign_cost_indices(esp_costs)
    unless result
      return result, message
    end

    #########
    #Create the entries
    #########

    Rails.logger.info "EspReader: create entries"
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

    Rails.logger.info "EspReader: add county coverage rules"
    #Add County Coverage Rules
    #from tServiceGrid
    esp_grids.shift
    result, message = create_or_update_coverages(esp_grids)
    unless result
      return result, message
    end

    Rails.logger.info "EspReader: add eligibility"
    #Add Eligibility
    #from tServiceCfg
    esp_configs.shift
    result, message = create_or_update_eligibility(esp_configs)
    unless result
      return result, message
    end

    Rails.logger.info "EspReader: create restrictions narrative"
    #Create restrictions narrative
    result, message = create_or_update_restrictions(esp_configs)
    unless result
      return result, message
    end

    Rails.logger.info "EspReader: add fares"
    #Add Fares
    esp_costs.shift
    result, message = create_or_update_fares(esp_costs)
    unless result
      return result, message
    end

    Rails.logger.info "EspReader: create fare table"
    #Add Fare Table
    result, message = create_fare_table(esp_costs)
    unless result
      return result, message
    end

    return true, ""

  end


  #########################
  # Create OneClick records from ESP
  #########################
  def create_or_update_provider esp_provider, service, create = false
    if create
      provider = Provider.new
    else
      provider = service.provider
    end

    #tProvider Column Names
    #['Name', 'Contact', 'ContactTitle', 'LocAddress', 'LocCity', 'LocState', 'LocZipCode', 'AreaCode1', 'Phone1', 'URL', 'Email', 'ProviderID']

    provider.name = esp_provider[@provider_idx["Name"]][0,128]
    provider.internal_contact_name = esp_provider[@provider_idx["Contact"]]
    provider.internal_contact_title = esp_provider[@provider_idx["ContactTitle"]]
    provider.address = esp_provider[@provider_idx["LocAddress"]]
    provider.city = esp_provider[@provider_idx["LocCity"]]
    provider.state = esp_provider[@provider_idx["LocState"]]
    provider.zip = esp_provider[@provider_idx["LocZipCode"]]
    provider.phone = '(' + esp_provider[@provider_idx["AreaCode1"]].to_s + ') ' + esp_provider[@provider_idx["Phone1"]].to_s
    provider.url = esp_provider[@provider_idx["URL"]]
    provider.email = esp_provider[@provider_idx["Email"]]
    provider.save

    provider.private_comments.where(locale: 'en').destroy_all
    provider.private_comments.create!(comment: fixup_comments(esp_provider[@provider_idx["Comments"]]), locale: 'en') if esp_provider[@provider_idx["Comments"]]

    if create #assign service to the new provider
      service.provider = provider
      service.service_type = ServiceType.find_by_code('paratransit')
      service.save
    end
  end

  def create_or_update_services esp_services

    #['ServiceID', 'ServiceRefID', 'OrgName', 'Contact', 'ContactTitle', 'Email', 'AreaCode1', 'Phone1', 'URL', 'ProviderID', 'CostComments', 'TimeSun1']

    services = []
    esp_services.each do |esp_service|

      SERVICE_DICT[esp_service[@service_idx['ServiceID']]] = esp_service[@service_idx['ServiceRefID']]
      service = Service.where(external_id: esp_service[@service_idx['ServiceRefID']]).first_or_initialize
      service.name = esp_service[@service_idx['OrgName']][0,128]
      service.internal_contact_name = esp_service[@service_idx['Contact']]
      service.internal_contact_title = esp_service[@service_idx['ContactTitle']]
      service.email = esp_service[@service_idx['Email']]
      service.phone = '(' + esp_service[@service_idx['AreaCode1']].to_s + ') ' + esp_service[@service_idx['Phone1']].to_s
      service.url = esp_service[@service_idx['URL']]

      service.service_type = ServiceType.find_by_code('paratransit')
      service.advanced_notice_minutes = 0  #TODO: Need to get this from ESP
      service.max_advanced_book_minutes = 0  #TODO: Need to get this from ESP
      service.active = true
      esp_provider = get_esp_provider(esp_service[@service_idx['ProviderID']])

      create_or_update_provider(esp_provider, service, service.provider.nil?)
      service.save

      #Clean up this service
      service.schedules.destroy_all
      service.service_coverage_maps.destroy_all
      service.service_accommodations.destroy_all
      service.service_characteristics.destroy_all
      service.service_trip_purpose_maps.destroy_all
      service.fare_structures.destroy_all
      service.public_comments.where(locale: 'en').destroy_all
      service.private_comments.where(locale: 'en').destroy_all

      service.public_comments.create!(comment: fixup_comments(esp_service[@service_idx['Comments']]), locale: 'en') if esp_service[@service_idx['Comments']]
      service.private_comments.create!(comment: fixup_comments(esp_service[@service_idx['LocalComments']]), locale: 'en') if esp_service[@service_idx['LocalComments']]

      #Add Curb to Curb by default
      accommodation = Accommodation.find_by_code('curb_to_curb')
      ServiceAccommodation.create(service: service, accommodation: accommodation)

      #Set new schedule
      (0..6).each do |day|
        index = @service_idx['TimeSun1'] + 2*day
        if esp_service[index] and esp_service[index+1]
          Schedule.create(service: service, start_seconds: Time.parse(esp_service[index][9..16]).seconds_since_midnight, end_seconds: Time.parse(esp_service[index+1][9..16]).seconds_since_midnight, day_of_week: day)
        end
      end

      #Set Cost Comments
      FareStructure.create(service: service, fare_type: 2, desc: esp_service[@service_idx['CostComments']])
      services << service
    end

    services
  end

  def fixup_comments comments
    return nil if comments.nil?
    comments.split(%r{\n+}).collect do |c|
      "<p>#{c}</p>"
    end.join
  end

  def create_or_update_eligibility esp_configs

    #['ServiceID', 'CfgNum', 'Item']
    esp_configs.each do |config|
      service = Service.find_by_external_id(SERVICE_DICT[config[@config_idx['ServiceID']]])
      case config[@config_idx['CfgNum']].to_i
      when 1,2
        result, message = add_accommodation(service, config[@config_idx['Item']])
      when 5
        result, message = add_eligibility(service, config[@config_idx['Item']])
      when 6 #ZipCode Restriction
        c = GeoCoverage.find_or_create_by(value: config[@config_idx['Item']]) do |gc|
          gc.coverage_type = 'zipcode'
        end
        ServiceCoverageMap.find_or_create_by(service: service, geo_coverage: c, rule: 'coverage_area')
        ServiceCoverageMap.find_or_create_by(service: service, geo_coverage: c, rule: 'endpoint_area')
        result = true
      else
        result = true
      end
      unless result
        return result, message
      end

    end
    return true, "Success"
  end

  def create_or_update_restrictions esp_configs
    service_comments_hash = {}
    #['ServiceID', 'CfgNum', 'Item']
    esp_configs.each do |config|
      service = Service.find_by_external_id(SERVICE_DICT[config[@config_idx['ServiceID']]])
      case config[@config_idx['CfgNum']].to_i
        when 4
          service_comments_hash[service.id] = (service_comments_hash[service.id] || "<p>Restrictions</p><ul>") + "<li>" + config[@config_idx['Item']].to_s + "</li>"
      end

    end

    Rails.logger.info "service_comments_hash:"
    Rails.logger.info service_comments_hash.ai

    service_comments_hash.each do |key, item|
      service = Service.find(key)
      c = service.public_comments.where(locale: 'en').first
      Rails.logger.info "for sch #{key} item #{item} c is #{c.ai}"
      if c.nil?
        service.public_comments.create! comment: item + "</ul>", locale: 'en'
      else
        c.update_attributes comment: item + "</ul>" + c.comment.to_s
      end
      Rails.logger.info "after processing:"
      service.public_comments.each do |c|
        Rails.logger.info c.ai
      end
      # service.public_comments.create! comment: item + "</ul>" + (service.public_comments || ""), locale: 'en'
      # service.save
    end

    return true, "Success"
  end

  def create_or_update_coverages esp_grids

    #['ServiceID', 'Grp', 'Item']

    esp_grids.each do |grid|
      service = Service.find_by_external_id(SERVICE_DICT[grid[@grid_idx['ServiceID']]])
      case grid[@grid_idx['Grp']].downcase
      when 'county'
        c = GeoCoverage.find_or_create_by(value: grid[@grid_idx['Item']]) do |gc|
          gc.coverage_type = 'county_name'
        end
        ServiceCoverageMap.find_or_create_by(service: service, geo_coverage: c, rule: 'coverage_area')
        ServiceCoverageMap.find_or_create_by(service: service, geo_coverage: c, rule: 'endpoint_area')
      end
    end
    return true, "Success"
  end

  def create_or_update_fares esp_configs

    #['ServiceID', 'CostType', 'Amount', 'CostUnit']

    esp_configs.each do |config|
      service = Service.find_by_external_id(SERVICE_DICT[config[@costs_idx['ServiceID']]])
      fare = FareStructure.find_by_service_id(service.id)
      case config[@costs_idx['CostType']].downcase
      when 'transportation'
        amount = config[@costs_idx['Amount']].to_f
        cost_unit = config[@costs_idx['CostUnit']].downcase.tr(" ", "")
        case cost_unit
          when 'roundtrip'
            amount = amount/2.0
          when "mile"
            fare.rate = amount
            fare.save
            next
        end
        if fare.base.nil? or amount >= fare.base.to_f
          fare.base = amount
          fare.fare_type = 0
          fare.save
        end
      end
    end
    return true, "Success"
  end

  def create_fare_table esp_configs

    #['ServiceID', 'CostType', 'Amount', 'CostUnit']

    service_comments_hash = {}

    esp_configs.each do |config|
      service = Service.find_by_external_id(SERVICE_DICT[config[@costs_idx['ServiceID']]])
      service_comments_hash[service.id] = (service_comments_hash[service.id] || "<table class='ALTtable'><tr><th>Cost Type</th><th>Amount</th><th>Cost Unit</th></tr>") +
          "<tr><td>" + config[@costs_idx['CostType']] +
          "</td><td>" + number_to_currency(config[@costs_idx['Amount']].to_f).to_s +
          "</td><td>" +  config[@costs_idx['CostUnit']] + "</td></tr>"
    end

    service_comments_hash.each do |key, item|
      service = Service.find(key)
      fare_structure = service.fare_structures.first #should only be one
      fare_structure.desc = item + "</table><br>" + (fare_structure.desc || "")
      fare_structure.save
      puts item
    end

    return true, "Success"
  end


  def add_accommodation(service, accommodation)

    case accommodation.downcase
    when 'wheelchair lift'
      accommodation = Accommodation.find_by_code('lift_equipped')
    when 'wheelchair/fold'
      accommodation = Accommodation.find_by_code('folding_wheelchair_accessible')
    when 'wheelchair/ motor', 'wheelchair/motor'
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
      return true, "Success"
    else
      return false, "Accommodation not found:  " + accommodation.to_s + ', For service:  ' + service.name.to_s + '.'
    end
    ServiceAccommodation.find_or_create_by(service: service, accommodation: accommodation)
    return true, "Success"
  end

  def add_eligibility(service, eligibility)
    #Give all rules in this eligibility the same group.
    group = (service.service_characteristics.pluck(:group).max || -1) + 1
    rules = eligibility.split(' and ')
    rules.each do |rule|
      if rule[0..2].downcase == 'age'
        characteristic = Characteristic.find_by_code('age')
        ServiceCharacteristic.create(service: service, characteristic: characteristic, value: rule.gsub(/[^0-9]/, ''), rel_code: 4, group: group)
        next
      end

      case rule.downcase
      when 'disabled'
        characteristic = Characteristic.find_by_code('disabled')
        ServiceCharacteristic.create(service: service, characteristic: characteristic, value: "true", group: group)
      when 'disabled veteran'
        characteristic = Characteristic.find_by_code('disabled')
        ServiceCharacteristic.create(service: service, characteristic: characteristic, value: "true", group: group)
        characteristic = Characteristic.find_by_code('veteran')
        ServiceCharacteristic.create(service: service, characteristic: characteristic, value: "true", group: group)
      when 'county resident'
        next
        # When county resident is required.  The person must also be a resident of the county in addition to traveling within that county.
        # The coverages were created previously.
        #service.coverage_areas.where(:coverage_type => "county_name").map(&:value).uniq.each do |county_name|
        #  c = GeoCoverage.find_or_create_by(value: county_name) do |gc|
        #    gc.coverage_type = 'county_name'
        #  end
        #  ServiceCoverageMap.find_or_create_by(service: service, geo_coverage: c, rule: 'residence')
        #end
      when 'military/veteran'
        characteristic = Characteristic.find_by_code('veteran')
        ServiceCharacteristic.create(service: service, characteristic: characteristic, value: "true", group: group)
      when 'medical purposes only'
        medical = TripPurpose.find_by_code('medical')
        ServiceTripPurposeMap.create(service: service, trip_purpose: medical)
      when 'no restrictions'
        return true, "Success"
      else
        return false, "Eligibility rule not found:  " + rule.to_s + ", for Service:  " + service.name.to_s + '.'
      end

    end
    return true, "Success"
  end

  #End create OneClick Records from ESP
  ######################
  def add_paratransit_buffer(service)
    case service.external_id
      when "45245457217490721111" #MARTA Paratransit
        service.service_coverage_maps.destroy_all
        b = Boundary.find_by_agency('Metropolitan Atlanta Rapid Transit Authority')
        gc = GeoCoverage.where(value: b.agency, coverage_type: 'polygon', geom: b.geom).first_or_create
        ServiceCoverageMap.where(service: service, geo_coverage: gc, rule: 'endpoint_area').first_or_create
        ServiceCoverageMap.where(service: service, geo_coverage: gc, rule: 'coverage_area').first_or_create
      when "65980602734372809999" #CATS Paratransit
        service.service_coverage_maps.destroy_all
        b = Boundary.find_by_agency('Cherokee Area Transportation System (CATS)')
        gc = GeoCoverage.where(value: b.agency, coverage_type: 'polygon', geom: b.geom).first_or_create
        ServiceCoverageMap.where(service: service, geo_coverage: gc, rule: 'endpoint_area').first_or_create
        ServiceCoverageMap.where(service: service, geo_coverage: gc, rule: 'coverage_area').first_or_create
      when "77900779520510731111" #Gwinnett Paratransit
        service.service_coverage_maps.destroy_all
        b = Boundary.find_by_agency('Gwinnett County Transit (GCT)')
        gc = GeoCoverage.where(value: b.agency, coverage_type: 'polygon', geom: b.geom).first_or_create
        ServiceCoverageMap.where(service: service, geo_coverage: gc, rule: 'endpoint_area').first_or_create
        ServiceCoverageMap.where(service: service, geo_coverage: gc, rule: 'coverage_area').first_or_create
      when "57874876269921009999" #CCT Paratransit
        service.service_coverage_maps.destroy_all
        b = Boundary.find_by_agency('Cobb Community Transit (CCT)')
        gc = GeoCoverage.where(value: b.agency, coverage_type: 'polygon', geom: b.geom).first_or_create
        ServiceCoverageMap.where(service: service, geo_coverage: gc, rule: 'endpoint_area').first_or_create
        ServiceCoverageMap.where(service: service, geo_coverage: gc, rule: 'coverage_area').first_or_create

    end
  end

end
