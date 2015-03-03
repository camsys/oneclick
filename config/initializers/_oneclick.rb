Oneclick::Application.configure do

  # defaults for all brands
  config.enable_rideshare = false
  ENV['SMTP_MAIL_ADDR'] ||= "smtp.gmail.com"
  ENV['SMTP_MAIL_PORT'] ||= '587'
  ENV['SMTP_MAIL_DOMAIN'] ||= "gmail.com"
  # Kiosk session timeouts
  ENV['SESSION_TIMEOUT'] ||= '10'
  ENV['SESSION_ALERT_TIMEOUT'] ||= '30'

  config.default_zoom = nil
  config.max_offset_from_desired = nil
  config.default_min_duration = 0 #minutes
  config.default_max_duration = 120 #minutes
  config.default_min_transfers = 0
  config.default_max_transfers = 2
  config.default_min_fare = 0
  config.default_max_fare = 50
  config.default_max_wait_time = 60 #minutes
  config.paratransit_duration_factor = 2.0
  config.minimum_paratransit_duration = 2.hours
  config.rideshare_duration_factor = 1.5
  config.minimum_rideshare_duration = (1.5).hours
  config.show_update_services = false
  config.min_drive_seconds = 180
  config.max_walk_seconds = 1200
  config.allows_booking = false
  config.replace_long_walks = false

  config.street_view_url = '/streetview.html'
  config.enable_sidewalk_obstruction = true
  config.sidewalk_feedback_query_buffer = 0.0001 #lat/lon degree

  config.initial_signup_question = false

  config.max_ui_duration = 2.hours
  config.min_ui_duration = 1.hours

  config.google_places_api_key = 'AIzaSyCvKyNoBzQNrBRuSRkipWye0pdj__HjrmU'
  config.google_radius_meters = 100000 #Used in the Autocomplete Geocoder to bias results

  config.time_zone = 'Eastern Time (US & Canada)'

  I18n.available_locales = [:en, :es] # default

  # service/provider logo upload related
  config.service_logo_format_list = %w(jpg jpeg gif png)
  config.service_logo_dimensions = [40, 40]
  config.provider_logo_format_list = %w(jpg jpeg gif png)
  config.provider_logo_dimensions = [40, 40]

  # standard usage report related
  config.application_launch_date = Date.new(2014,1,1) # default
  config.usage_report_last_n = 4
  config.kiosk_available = false

  # application logo upload related
  config.application_logo_format_list = %w(jpg jpeg gif png)
  config.application_logo_dimensions = [440, 50]

  # poi loading
  config.poi_is_loading = false

  # maximum how many services to be displayed
  config.max_number_of_specialized_services_to_show = nil # nil means no limitation


  case ENV['BRAND'] || 'arc'
  when 'arc'
    config.host = 'oneclick-arc.camsys-apps.com'
    config.ui_logo = 'arc/logo.png'
    config.logo_text = "A R C logo - Simply Get There"
    config.geocoder_components = 'country:US'
    config.map_bounds = [[33.457797,-84.754028], [34.090199,-83.921814]]
    config.geocoder_bounds = [[33.737147,-84.406634], [33.764125,-84.370361]]
    config.open_trip_planner = "http://otpv1-arc.camsys-apps.com:8080/otp/routers/atl/plan?"
    config.transit_respects_ada = false
    config.taxi_fare_finder_api_key = "SIefr5akieS5"
    config.taxi_fare_finder_api_city = "Atlanta"
    config.enable_rideshare = true
    config.name = 'ARC 1-Click'
    ENV['SMTP_MAIL_USER_NAME'] ||= "oneclick.arc.camsys"
    ENV['SMTP_MAIL_PASSWORD'] ||= "CatDogMonkey"
    ENV['SYSTEM_SEND_FROM_ADDRESS'] ||= "donotreply@atlantaregional.com"
    ENV['SEND_FEEDBACK_TO_ADDRESS'] ||= "1-Click@camsys.com"
    ENV['GOOGLE_GEOCODER_ACCOUNT'] ||=  "gme-cambridgesystematics"
    ENV['GOOGLE_GEOCODER_KEY'] ||=      "dXP8tsyrLYECMWGxgs5LA9Li0MU="
    ENV['GOOGLE_GEOCODER_CHANNEL'] ||=  "ARC_ONECLICK"
    ENV['GOOGLE_GEOCODER_TIMEOUT'] ||= "5"
    config.enable_feedback = true
    config.traveler_read_all_organization_feedback = true
    config.agent_read_feedback = true
    config.provider_read_all_feedback = true
    config.tripless_feedback = false
    honeybadger_api_key = 'ba642a71'
    config.poi_file = 'db/arc_poi_data/combined.csv'
    config.show_update_services = true
    config.default_county = ''
    config.state = 'GA'
    config.max_number_of_specialized_services_to_show = 3
    config.replace_long_walks = true

  when 'broward'
    config.host = 'oneclick-broward.camsys-apps.com'
    config.ui_logo = 'broward/logo.png'
    config.logo_text = "Broward logo - One Click"
    config.geocoder_components = 'country:US'
    config.map_bounds = [[26.427309, -80.347081], [25.602294, -80.061728]]
    config.geocoder_bounds = [[26.427309, -80.347081], [25.602294, -80.061728]]
    config.open_trip_planner = "http://otp-broward.camsys-apps.com:8080/otp/routers/broward/plan?"
    config.transit_respects_ada = false
    config.taxi_fare_finder_api_key = "SIefr5akieS5"
    config.taxi_fare_finder_api_city = "Miami"
    config.name = '1-Click'
    ENV['SMTP_MAIL_USER_NAME'] ||= "oneclick.broward.camsys"
    ENV['SMTP_MAIL_PASSWORD'] ||= "CatDogMonkey"
    ENV['SYSTEM_SEND_FROM_ADDRESS'] ||= "donotreply@browardmpo.org"
    ENV['SEND_FEEDBACK_TO_ADDRESS'] ||= "1-Click@camsys.com"
    ENV['GOOGLE_GEOCODER_ACCOUNT'] ||=  "gme-cambridgesystematics"
    ENV['GOOGLE_GEOCODER_KEY'] ||=   "dXP8tsyrLYECMWGxgs5LA9Li0MU="
    ENV['GOOGLE_GEOCODER_CHANNEL'] ||=  "ARC_ONECLICK"
    ENV['GOOGLE_GEOCODER_TIMEOUT'] ||=  "5"
    config.enable_feedback = true
    config.traveler_read_all_organization_feedback = false
    config.agent_read_feedback = false
    config.provider_read_all_feedback = false
    config.tripless_feedback = false
    honeybadger_api_key = '789c7911'
    config.poi_file = 'db/broward_poi_data/broward-poi-from-arcgis.csv'
    config.default_county = 'Broward'
    config.state = 'FL'
    I18n.available_locales = [:en, :es, :ht]

  when 'pa'
    config.host = 'oneclick-pa.camsys-apps.com'
    config.ui_logo = 'pa/logo.jpg'
    config.logo_text = "Pennsylvania logo - Find My Ride"
    config.geocoder_components = 'country:US'
    # TODO Do we maybe need different bounds for kiosk vs. default?
    config.map_bounds      = [[40.0262999543423,  -76.56372070312499], [39.87970800405549, -76.90189361572266]]
    config.geocoder_bounds = [[40.0262999543423,  -76.56372070312499], [39.87970800405549, -76.90189361572266]]
    config.default_zoom = 12
    config.open_trip_planner = "http://otpv1-arc.camsys-apps.com:8082/otp/routers/pa/plan?"
    config.transit_respects_ada = false
    config.taxi_fare_finder_api_key = "SIefr5akieS5"
    config.taxi_fare_finder_api_city = "Harrisburg-PA"
    config.name = '1-Click/PA'
    ENV['SMTP_MAIL_USER_NAME'] ||= "oneclick.arc.camsys"
    ENV['SMTP_MAIL_PASSWORD'] ||= "CatDogMonkey"
    ENV['SYSTEM_SEND_FROM_ADDRESS'] ||= "donotreply@rabbittransit.org"
    ENV['SEND_FEEDBACK_TO_ADDRESS'] ||= "1-Click@camsys.com"
    ENV['GOOGLE_GEOCODER_ACCOUNT'] ||=  "gme-cambridgesystematics"
    ENV['GOOGLE_GEOCODER_KEY'] ||=      "dXP8tsyrLYECMWGxgs5LA9Li0MU="
    ENV['GOOGLE_GEOCODER_CHANNEL'] ||=  "ARC_ONECLICK"
    ENV['GOOGLE_GEOCODER_TIMEOUT'] ||=  "5"
    config.enable_feedback = true
    config.traveler_read_all_organization_feedback = false
    config.agent_read_feedback = false
    config.provider_read_all_feedback = false
    config.tripless_feedback = false
    honeybadger_api_key = 'f49faffa'
    config.poi_file = 'db/pa/pa-poi-from-arcgis.csv'
    config.default_county = 'York'
    config.state = 'PA'

    config.max_walk_seconds = 3600

    ##Ecolane Variables
    config.ecolane_system_id = ENV['ECOLANE_SYSTEM_ID']
    config.ecolane_x_ecolane_token = ENV['X_ECOLANE_TOKEN']
    config.ecolane_base_url = "https://apiserver.ecolane.com"
    I18n.available_locales = [:en]

    #for PA, we ask a follow up question after a person creates an account
    config.initial_signup_question = true
    config.allows_booking = true

    config.kiosk_available = true
  when 'jta'
    config.host = 'transportal.net'
    config.ui_logo = 'jta/logo.png'
    config.logo_text = "J T A logo - TransPortal"
    config.geocoder_components = 'country:US'
    # TODO Do we maybe need different bounds for kiosk vs. default?
    config.map_bounds      = [[30.0668986565,-82.0920740215],[30.5909384888,-81.319458582]]
    config.geocoder_bounds = [[30.0668986565,-82.0920740215],[30.5909384888,-81.319458582]]
    config.default_zoom = 12
    config.open_trip_planner = "http://otpv1-jta.camsys-apps.com:8080/otp/routers/jta/plan?"
    config.transit_respects_ada = false
    config.taxi_fare_finder_api_key = "SIefr5akieS5"
    config.taxi_fare_finder_api_city = "Jacksonville-FL"
    config.name = '1-Click/JTA'
    ENV['SMTP_MAIL_USER_NAME'] ||= "oneclick.arc.camsys" # TODO
    ENV['SMTP_MAIL_PASSWORD'] ||= "CatDogMonkey" # TODO
    ENV['SYSTEM_SEND_FROM_ADDRESS'] ||= "donotreply@rabbittransit.org" # TODO
    ENV['SEND_FEEDBACK_TO_ADDRESS'] ||= "1-Click@camsys.com"
    ENV['GOOGLE_GEOCODER_ACCOUNT'] ||=   "gme-cambridgesystematics"
    ENV['GOOGLE_GEOCODER_KEY'] ||=      "dXP8tsyrLYECMWGxgs5LA9Li0MU="
    ENV['GOOGLE_GEOCODER_CHANNEL'] ||=  "ARC_ONECLICK"
    ENV['GOOGLE_GEOCODER_TIMEOUT'] ||=  "5"
    config.enable_feedback = true
    config.traveler_read_all_organization_feedback = true
    config.agent_read_feedback = true
    config.provider_read_all_feedback = true
    config.tripless_feedback = false
    honeybadger_api_key = '0447225c'
    config.poi_file = 'db/jta/locations.csv'
    config.default_county = 'Duval'
    config.state = 'FL'
    config.max_walk_seconds = 3600

  when 'ieuw'
    config.host = 'oneclick-ieuw.camsys-apps.com'
    config.ui_logo = 'ieuw/logo.png'
    config.logo_text = "Inland Empire logo - Vet Link"
    config.geocoder_components = 'country:US'
    # TODO Do we maybe need different bounds for kiosk vs. default?
    config.map_bounds      = [[33.163,-117.874],[36.053,-114.033]]
    config.geocoder_bounds = [[33.163,-117.874],[36.063,-114.033]]
    config.default_zoom = 12
    config.open_trip_planner = "http://otp-ieuw.camsys-apps.com:8080/otp/routers/ieuw/plan?"
    config.transit_respects_ada = false
    config.taxi_fare_finder_api_key = "SIefr5akieS5"
    config.taxi_fare_finder_api_city = "Rancho-Cucamonga-CA"
    config.name = '1-Click/IEUW'
    ENV['SMTP_MAIL_USER_NAME'] ||= "oneclick.arc.camsys" # TODO
    ENV['SMTP_MAIL_PASSWORD'] ||= "CatDogMonkey" # TODO
    ENV['SYSTEM_SEND_FROM_ADDRESS'] ||= "donotreply@ieuw.org" # TODO
    ENV['SEND_FEEDBACK_TO_ADDRESS'] ||= "1-Click@camsys.com"
    ENV['GOOGLE_GEOCODER_ACCOUNT'] ||=  "gme-cambridgesystematics"
    ENV['GOOGLE_GEOCODER_KEY'] ||=      "dXP8tsyrLYECMWGxgs5LA9Li0MU="
    ENV['GOOGLE_GEOCODER_CHANNEL'] ||=  "IEUW_ONECLICK"
    ENV['GOOGLE_GEOCODER_TIMEOUT'] ||=  "5"
    config.enable_feedback = true
    config.traveler_read_all_organization_feedback = true
    config.agent_read_feedback = true
    config.provider_read_all_feedback = true
    config.tripless_feedback = false
    honeybadger_api_key = '8640caf4'
    config.poi_file = 'db/ieuw/Combined.txt'
    config.default_county = 'San Bernandino'
    config.state = 'CA'

    config.max_walk_seconds = 3600

    config.time_zone = 'Pacific Time (US & Canada)'

  when 'ma'
    config.host = 'oneclick.camsys-apps.com'
    config.ui_logo = 'ma/logo.png'
    config.logo_text = "1-Click"
    config.geocoder_components = 'country:US'
    # TODO Do we maybe need different bounds for kiosk vs. default?
    config.map_bounds      = [[40.664559, -74.104039],[43.244470, -69.148697]]
    config.geocoder_bounds = [[40.664559, -74.104039],[43.244470, -69.148697]]
    config.default_zoom = 12
    config.open_trip_planner = "http://otp-extra.camsys-apps.com:8080/otp/routers/default/plan?"
    config.transit_respects_ada = false
    config.taxi_fare_finder_api_key = "SIefr5akieS5"
    config.taxi_fare_finder_api_city = "Boston"
    config.name = '1-Click/MA'
    ENV['SMTP_MAIL_USER_NAME'] ||= "oneclick.arc.camsys" # TODO
    ENV['SMTP_MAIL_PASSWORD'] ||= "CatDogMonkey" # TODO
    ENV['SYSTEM_SEND_FROM_ADDRESS'] ||= "donotreply@1-click.org" # TODO
    ENV['SEND_FEEDBACK_TO_ADDRESS'] ||= "1-Click@camsys.com"
    ENV['GOOGLE_GEOCODER_ACCOUNT'] ||=  "gme-cambridgesystematics"
    ENV['GOOGLE_GEOCODER_KEY'] ||=      "dXP8tsyrLYECMWGxgs5LA9Li0MU="
    ENV['GOOGLE_GEOCODER_CHANNEL'] ||=  "ARC_ONECLICK"
    ENV['GOOGLE_GEOCODER_TIMEOUT'] ||=  "5"
    config.enable_feedback = true
    config.traveler_read_all_organization_feedback = true
    config.agent_read_feedback = true
    config.provider_read_all_feedback = true
    config.tripless_feedback = false
    honeybadger_api_key = 'c23d4c30'
    #config.poi_file = 'db/jta/locations.csv'
    config.default_county = 'Suffolk'
    config.state = 'MA'

    config.max_walk_seconds = 3600

    when 'uta'
      config.host = 'oneclick-uta.camsys-apps.com'
      config.logo_text = "UTA"
      config.geocoder_components = "country:us"
      # TODO Do we maybe need different bounds for kiosk vs. default?
      config.map_bounds      = [[37,-114.1],[42,-109]]
      config.geocoder_bounds = [[37,-114.1],[42,-109]]
      config.default_zoom = 12
      config.open_trip_planner = "http://otp-uta.camsys-apps.com:8080/otp/routers/uta/plan?"
      config.transit_respects_ada = false
      config.taxi_fare_finder_api_key = "SIefr5akieS5"
      config.taxi_fare_finder_api_city = "SLC"
      config.name = '1-Click/UTA'
      ENV['SMTP_MAIL_USER_NAME'] ||= "oneclick.arc.camsys" # TODO
      ENV['SMTP_MAIL_PASSWORD'] ||= "CatDogMonkey" # TODO
      ENV['SYSTEM_SEND_FROM_ADDRESS'] ||= "donotreply@camsys.com"
      ENV['SEND_FEEDBACK_TO_ADDRESS'] ||= "1-Click@camsys.com"
      ENV['GOOGLE_GEOCODER_ACCOUNT'] ||=   "gme-cambridgesystematics"
      ENV['GOOGLE_GEOCODER_KEY'] ||=      "dXP8tsyrLYECMWGxgs5LA9Li0MU="
      ENV['GOOGLE_GEOCODER_CHANNEL'] ||=  "ARC_ONECLICK"
      ENV['GOOGLE_GEOCODER_TIMEOUT'] ||=  "5"
      config.enable_feedback = true
      config.traveler_read_all_organization_feedback = true
      config.agent_read_feedback = true
      config.provider_read_all_feedback = true
      config.tripless_feedback = false
      honeybadger_api_key = '0447225c'
      config.default_county = 'Salt Lake'
      config.state = 'UT'
      config.max_walk_seconds = 3600


    else
    raise "Brand '#{config.brand}' not supported"
  end

  ENV['HOST'] ||= config.host

  Rails.logger.info "Rails.application.routes.default_url_options before:"
  Rails.logger.info Rails.application.routes.default_url_options.ai
  if Rails.application.routes.default_url_options[:host].nil?
    host = case Rails.env
    when 'production'
      ENV['HOST']
    when 'qa', 'staging'
      parts = config.host.split(%r{\.}, 2)
      parts[0] + '-qa.' + parts[1]
    when 'development'
      'localhost:3000'
    when 'integration'
      parts = config.host.split(%r{\.}, 2)
      parts[0] + '-int.' + parts[1]
    when 'test'
      'example.com'
    else
      raise "Unhandled Rails.env #{Rails.env}"
    end
    Rails.application.routes.default_url_options[:host] = host
  end
  Rails.logger.info "Rails.application.routes.default_url_options after:"
  Rails.logger.info Rails.application.routes.default_url_options.ai

  case config.ui_mode
  when 'desktop'
    config.google_place_search = 'geocode'
  when 'kiosk'
    config.google_place_search = 'places'
  else
    raise "UI mode #{config.ui_mode} not supported."
  end

  # # SMTP Mail Sender Account
  ENV['SMTP_MAIL_ADDR'] ||=           "smtp.gmail.com"
  ENV['SMTP_MAIL_PORT'] ||=           "587"
  ENV['SMTP_MAIL_DOMAIN'] ||=         "gmail.com"
  ENV['SMTP_MAIL_USER_NAME'] ||=      "oneclick.broward.camsys"
  ENV['SMTP_MAIL_PASSWORD'] ||=       "CatDogMonkey"

  Honeybadger.configure do |config|
    config.api_key = honeybadger_api_key
    # Uncomment this if you want to send honeybadger notices from development:
    # config.development_environments = ['test', 'cucumber']
  end

  # General UI configuration settings
  config.ui_typeahead_delay = 300       # milliseconds delay between keystrokes before a query is sent to the server to retrieve a typeahead list
  config.ui_typeahead_min_chars = 4     # minimum number of characters to initiate a query
  config.ui_typeahead_list_length = 10  # max number of items displayed in the typeahead list
  config.ui_search_poi_items = 10       # max number of matching POIs to return in a search
  config.ui_min_geocode_chars = 5       # Minimum number of characters (not including whitespace) before sending to the geocoder

  config.address_cache_expire_seconds = 3600 # seconds to keep addresses returned from the geocoder in the cache
  config.return_trip_delay_mins = 120   # minutes needed at last trip place before scheduling the return trip
  config.OTP_retry_count = 3            #How many times do we retry getting a response from OTP before giving up.
  config.user_guide_url = "https://s3.amazonaws.com/oneclick-bin/documentation/1-Click+Guide.pdf"

  #Special Fixed-Route Fare
  config.discount_fare_multiplier = 0
  config.discount_fare_age = 65
  config.discount_fare_active = false

  if ENV['UI_MODE'] == 'kiosk'
    config.trip_time_ahead_mins = 30
  else
    config.trip_time_ahead_mins = 15     #interval: This is not used as the default trip ahead time.  It is used as the interval (which is actually ignored by the front-end)
  end

  config.default_trip_ahead_mins = 120    #How many minutes into the future should the default outbound trip time be? (It is rounded to the next 15 min interval)

  # Note that as of 2014-06-04, at least, these timeouts are only used by rideshare.
  config.remote_read_timeout_seconds = 10    # seconds to wait before timing out reading a page through a web request
  config.remote_request_timeout_seconds = 10 # seconds to wait for a remote web site/api to respond to a request

  ROLES = [
    'System Administrator',
    'Agency Administrator',
    'Agency Agent',
    'Provider Staff'
  ]

  config.session_timeout       = ENV['SESSION_TIMEOUT']
  config.session_alert_timeout = ENV['SESSION_ALERT_TIMEOUT']

  # See https://github.com/mojombo/chronic#time-zones
  Chronic.time_class = Time.zone

  # I18n.available_locales << :tags # when this locale is enabled, display translation_tags instead of translated text
  config.translation_tag_locale_text = 'Tags'

  config.service_max_allow_advanced_book_days = 365 # 1 year
end

class String
  def to_sample_email suffix
    downcase.gsub(/[^a-z\s]/, '').gsub(/\s/, '_') + '_' + suffix + '@camsys.com'
  end
end
