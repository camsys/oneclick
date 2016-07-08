Oneclick::Application.configure do

  #Move these configurations
  # Rules for config variables
  # Every configurable will be accessed via a call to the projects' config
  # e.g., Oneclick::Application.config.<config name>
  # Configs that should be kept secret (e.g., EMAIL Passwords, Geocoder Info, etc)
  # will be stored in ENV variables, but ultimately will be copied to a config
  # Configs in this file are the defaults.  To overwrite the defaults, add an entry to the OneclickConfigurations table

  #Remove these via improved ecolane support
  config.ecolane_base_url = "https://apiserver.ecolane.com"
  config.get_fares_from_ecolane = false
  config.service_max_allow_advanced_book_days = 365
  config.ada_funding_sources = []

  unless Rails.env.production?
    OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
  end

  #Used by geocoding stops.  9000 new stops needing to be geocoded will approach the daily limit
  #This parameter tells us to only do the first 100 or so stops.
  if Rails.env.production?
    config.limit_geocoding = false
  else
    config.limit_geocoding = true
  end

  #Only used if limit_gecoding = true
  config.geocoding_limit = 100

  #Support email
  config.support_emails = 'dedwards@camsys.com' #where to send emails for maintenance alerts

  #Review the necessity of these variables
  config.show_update_services = false
  config.min_drive_seconds = 180
  config.default_min_duration = 0 #minutes
  config.default_min_transfers = 0
  config.default_min_fare = 0
  config.initial_signup_question = false
  config.max_ui_duration = 2.hours
  config.min_ui_duration = 1.hours
  config.poi_is_loading = false
  config.allows_booking = false
  config.restrict_results_registered_services = false #Only show results on the review page from services that the user is registered to book with (used at PA)

    config.google_radius_meters = 100000 #Used in the Autocomplete Geocoder to bias results
  config.max_number_of_specialized_services_to_show = nil # nil means no limitation
  config.show_legend = true   # the ability to see the legend on the review page

  #Modes
  config.enable_rideshare = false
  config.replace_long_walks = false

  #Logging
  config.log_level = 3

  # Maps
  config.default_zoom = nil
  config.max_offset_from_desired = nil
  config.street_view_url = '/streetview.html'

  # Enable Sidewalk Obstruction
  config.enable_sidewalk_obstruction = true
  config.sidewalk_feedback_query_buffer = 0.0001 #lat/lon degree

  # Trip Plan Filter Presents
  config.default_max_duration = 120 #minutes


  config.default_max_transfers = 2
  config.default_max_fare = 50
  config.default_max_wait_time = 60 #minutes
  config.max_walk_seconds = 1200

  # Paratransit Time Estimate Constants
  config.paratransit_duration_factor = 4.0
  config.minimum_paratransit_duration = 0
  config.default_paratransit_duration = 2.hours

  # Rideshare Time Estimate Constants
  config.rideshare_duration_factor = 1.5
  config.minimum_rideshare_duration = (1.5).hours

  # Locales/Translations
  I18n.available_locales = [:en, :es] # default

  # service/provider logo upload related
  config.service_logo_format_list = %w(jpg jpeg gif png)
  config.service_logo_dimensions = [40, 40]
  config.provider_logo_format_list = %w(jpg jpeg gif png)
  config.provider_logo_dimensions = [40, 40]

  # application logo upload related
  config.application_logo_format_list = %w(jpg jpeg gif png)
  config.application_logo_dimensions = [440, 50]
  config.favicon_format_list = %w(ico png)

  # standard usage report related
  config.application_launch_date = Date.new(2014,1,1) # default
  config.usage_report_last_n = 4

  #Default SSL Setting
  config.force_ssl = false

  #API Activation:  API is still in beta.  Need ability to turn it off on a per-instance basis
  config.api_activated = true

  config.host = 'oneclick.camsys-apps.com'
  config.logo_text = "1-Click"
  config.ui_logo = '/assets/logo.png'
  config.logo_text = "1-Click"
  config.favicon = ''
  config.mobile_favicon = ''
  config.tablet_favicon = ''
  config.geocoder_components = 'country:US'
  config.map_bounds      = [[39.496227, -105.338796], [39.998374, -104.688062]]
  config.geocoder_bounds = [[39.496227, -105.338796], [39.998374, -104.688062]]
  config.default_county = "Denver"
  config.default_zoom = 12
  config.landmarks_file = "https://s3.amazonaws.com/oneclick-bin/tmp/landmarks.csv"

  #Open Trip Planner Configs
  config.open_trip_planner = "http://otp-rtd.camsys-apps.com:8080/otp/routers/default"
  config.otp_walk_reluctance = "20" #If an OTP Trip is set to optmimize walkTime, then this walk_reluctance is used to discourage walking time
  config.otp_transfer_penalty = "1800" #If an OTP Trip is set to optimize/minimize transfers then this value replaces the default transfer penalty
  config.transit_respects_ada = false

  config.taxi_fare_finder_api_city = "Denver"
  config.name = '1-Click/RTD'

  config.enable_feedback = true
  config.traveler_read_all_organization_feedback = true
  config.agent_read_feedback = true
  config.provider_read_all_feedback = true
  config.tripless_feedback = false
  config.state = 'CO'

  config.show_characteristic_logos = false
  config.user_radio_buttons = false

  config.max_walk_seconds = 3600
  config.enable_satisfaction_surveys = false
  config.show_intermediate_stops = true

  config.google_place_search = 'geocode'
  config.use_google_analytics = true

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
  config.trip_time_ahead_mins = 15     #interval: This is not used as the default trip ahead time.  It is used as the interval (which is actually ignored by the front-end)
  config.default_trip_ahead_mins = 120    #How many minutes into the future should the default outbound trip time be? (It is rounded to the next 15 min interval)

  # Note that as of 2014-06-04, at least, these timeouts are only used by rideshare.
  config.remote_read_timeout_seconds = 10    # seconds to wait before timing out reading a page through a web request
  config.remote_request_timeout_seconds = 10 # seconds to wait for a remote web site/api to respond to a request

  # See https://github.com/mojombo/chronic#time-zones
  Chronic.time_class = Time.zone

  # I18n.available_locales << :tags # when this locale is enabled, display translation_tags instead of translated text
  config.translation_tag_locale_text = 'Tags'

  ##########################################
  # Secret Settings from Application.yml.  They can also be set in OneclickConfiguration
  ##########################################

  # Oneclick Back-end URL
  # (This is a temporary solution to deal with create_map proxy rendering issue)
  config.oneclick_url = ENV['ONECLICK_URL'] || 'http://localhost:3000'

  # Prefix for email trip planner url link
  config.email_trip_planner_url = ENV['TRIP_PLANNER_URL'] || 'http://rtd-dev.camsys-apps/#/plan/'
  
  # From email address
  config.email_sender = ENV["SYSTEM_SEND_FROM_ADDRESS"] || '1-Click@camsys.com'

  # SMTP Mail Sender Account
  config.smtp_mail_addr = ENV['SMTP_MAIL_ADDR']
  config.smtp_mail_port = ENV['SMTP_MAIL_PORT']
  config.smtp_mail_domain = ENV['SMTP_MAIL_DOMAIN']
  config.smtp_mail_user_name = ENV['SMTP_MAIL_USER_NAME']
  config.smtp_mail_password = ENV['SMTP_MAIL_PASSWORD']

  # Mailer Settings
  config.taxi_fare_finder_api_key = ENV['TAXI_FARE_FINDER_API_KEY']

  #where to send emails for maintenance alerts
  config.support_emails = ENV['SUPPORT_EMAILS']

  config.google_places_api_key = ENV['GOOGLE_PLACES_API_KEY']

  ##########################################
  # END SECRET SETTINGS
  ##########################################

end


class String
  def to_sample_email suffix
    downcase.gsub(/[^a-z\s]/, '').gsub(/\s/, '_') + '_' + suffix + '@camsys.com'
  end
end
