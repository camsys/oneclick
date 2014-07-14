# use as Rails.application.config.brand
Oneclick::Application.config.brand = ENV['BRAND'] || 'arc'
Oneclick::Application.config.ui_mode = ENV['UI_MODE'] || 'desktop'

# defaults for all brands
Oneclick::Application.config.enable_rideshare = false
ENV['SMTP_MAIL_ADDR'] ||= "smtp.gmail.com"
ENV['SMTP_MAIL_PORT'] ||= '587'
ENV['SMTP_MAIL_DOMAIN'] ||= "gmail.com"
# Kiosk session timeouts
ENV['SESSION_TIMEOUT'] ||= '10'
ENV['SESSION_ALERT_TIMEOUT'] ||= '30'

Oneclick::Application.config.default_zoom = nil
Oneclick::Application.config.max_offset_from_desired = 3.hours
Oneclick::Application.config.paratransit_duration_factor = 2.0
Oneclick::Application.config.minimum_paratransit_duration = 2.hours
Oneclick::Application.config.rideshare_duration_factor = 1.5
Oneclick::Application.config.minimum_rideshare_duration = (1.5).hours
Oneclick::Application.config.show_update_services = false
Oneclick::Application.config.min_drive_seconds = 180
Oneclick::Application.config.max_walk_seconds = 1200

Oneclick::Application.config.max_ui_duration = 2.hours
Oneclick::Application.config.min_ui_duration = 1.hours

Oneclick::Application.config.google_places_api_key = 'AIzaSyCvKyNoBzQNrBRuSRkipWye0pdj__HjrmU'

I18n.available_locales = [:en, :es] # default

case ENV['BRAND'] || 'arc'
when 'arc'
  Oneclick::Application.config.host = 'oneclick-arc.camsys-apps.com'
  Oneclick::Application.config.ui_logo = 'arc/arc-logo.png'
  Oneclick::Application.config.geocoder_components = 'administrative_area:GA|country:US'
  Oneclick::Application.config.map_bounds = [[33.457797,-84.754028], [34.090199,-83.921814]]
  Oneclick::Application.config.geocoder_bounds = [[33.737147,-84.406634], [33.764125,-84.370361]]  
  Oneclick::Application.config.open_trip_planner = "http://otpv1-arc.camsys-apps.com:8080/otp/routers/atl/plan?"
  Oneclick::Application.config.taxi_fare_finder_api_key = "SIefr5akieS5"
  Oneclick::Application.config.taxi_fare_finder_api_city = "Atlanta"
  Oneclick::Application.config.enable_rideshare = true
  Oneclick::Application.config.name = 'ARC OneClick'
  ENV['SMTP_MAIL_USER_NAME'] = "oneclick.arc.camsys"
  ENV['SMTP_MAIL_PASSWORD'] = "CatDogMonkey"
  ENV['SYSTEM_SEND_FROM_ADDRESS'] = "donotreply@atlantaregional.com"
  ENV['SEND_FEEDBACK_TO_ADDRESS'] = "OneclickARC@camsys.com"
  ENV['GOOGLE_GEOCODER_ACCOUNT']=  "gme-cambridgesystematics"
  ENV['GOOGLE_GEOCODER_KEY']=      "dXP8tsyrLYECMWGxgs5LA9Li0MU="
  ENV['GOOGLE_GEOCODER_CHANNEL']=  "ARC_ONECLICK"
  ENV['GOOGLE_GEOCODER_TIMEOUT']= "5"
  Oneclick::Application.config.enable_feedback = true
  Oneclick::Application.config.traveler_read_all_organization_feedback = true
  Oneclick::Application.config.agent_read_feedback = true
  Oneclick::Application.config.provider_read_all_feedback = true
  Oneclick::Application.config.tripless_feedback = false
  honeybadger_api_key = 'ba642a71'
  Oneclick::Application.config.poi_file = 'db/arc_poi_data/CommFacil_20131015.txt'
  Oneclick::Application.config.show_update_services = true
  Oneclick::Application.config.default_county = ''
  Oneclick::Application.config.state = 'GA'

when 'broward'
  Oneclick::Application.config.host = 'oneclick-broward.camsys-apps.com'
  Oneclick::Application.config.ui_logo = 'broward/Broward_211_Get_Connected_get_answers.jpg'
  Oneclick::Application.config.geocoder_components = 'administrative_area:FL|country:US'
  Oneclick::Application.config.map_bounds = [[26.427309, -80.347081], [25.602294, -80.061728]]
  Oneclick::Application.config.geocoder_bounds = [[26.427309, -80.347081], [25.602294, -80.061728]]
  Oneclick::Application.config.open_trip_planner = "http://otp-broward.camsys-apps.com:8081/otp/routers/broward/plan?"
  Oneclick::Application.config.taxi_fare_finder_api_key = "SIefr5akieS5"
  Oneclick::Application.config.taxi_fare_finder_api_city = "Miami"
  Oneclick::Application.config.name = 'OneClick'
  ENV['SMTP_MAIL_USER_NAME'] = "oneclick.broward.camsys"
  ENV['SMTP_MAIL_PASSWORD'] = "CatDogMonkey"
  ENV['SYSTEM_SEND_FROM_ADDRESS'] = "donotreply@browardmpo.org"
  ENV['SEND_FEEDBACK_TO_ADDRESS'] = "oneclick@Camsys.com"
  ENV['GOOGLE_GEOCODER_ACCOUNT']=  "gme-cambridgesystematics"
  ENV['GOOGLE_GEOCODER_KEY']=      "dXP8tsyrLYECMWGxgs5LA9Li0MU="
  ENV['GOOGLE_GEOCODER_CHANNEL']=  "ARC_ONECLICK"
  ENV['GOOGLE_GEOCODER_TIMEOUT']=  "5"
  Oneclick::Application.config.enable_feedback = true
  Oneclick::Application.config.traveler_read_all_organization_feedback = false
  Oneclick::Application.config.agent_read_feedback = false
  Oneclick::Application.config.provider_read_all_feedback = false
  Oneclick::Application.config.tripless_feedback = false
  honeybadger_api_key = '789c7911'
  Oneclick::Application.config.poi_file = 'db/broward_poi_data/broward-poi-from-arcgis.csv'
  Oneclick::Application.config.default_county = 'Broward'
  Oneclick::Application.config.state = 'FL'
  I18n.available_locales = [:en, :es, :ht]

when 'pa'
  Oneclick::Application.config.host = 'oneclick-pa.camsys-apps.com'
  Oneclick::Application.config.ui_logo = 'pa/penndotLogo.jpg'
  Oneclick::Application.config.geocoder_components = 'administrative_area:PA|country:US'
  # TODO Do we maybe need different bounds for kiosk vs. default?
  Oneclick::Application.config.map_bounds      = [[40.0262999543423,  -76.56372070312499], [39.87970800405549, -76.90189361572266]]
  Oneclick::Application.config.geocoder_bounds = [[40.0262999543423,  -76.56372070312499], [39.87970800405549, -76.90189361572266]]
  Oneclick::Application.config.default_zoom = 12
  Oneclick::Application.config.open_trip_planner = "http://otpv1-arc.camsys-apps.com:8081/otp/routers/pa/plan?"
  Oneclick::Application.config.taxi_fare_finder_api_key = "SIefr5akieS5"
  Oneclick::Application.config.taxi_fare_finder_api_city = "Harrisburg-PA"
  Oneclick::Application.config.name = '1-Click/PA'
  ENV['SMTP_MAIL_USER_NAME'] = "oneclick.pa.camsys"
  ENV['SMTP_MAIL_PASSWORD'] = "CatDogMonkey"
  ENV['SYSTEM_SEND_FROM_ADDRESS'] = "donotreply@rabbittransit.org"
  ENV['SEND_FEEDBACK_TO_ADDRESS'] = "Oneclick@Camsys.com"
  ENV['GOOGLE_GEOCODER_ACCOUNT']=  "gme-cambridgesystematics"
  ENV['GOOGLE_GEOCODER_KEY']=      "dXP8tsyrLYECMWGxgs5LA9Li0MU="
  ENV['GOOGLE_GEOCODER_CHANNEL']=  "ARC_ONECLICK"
  ENV['GOOGLE_GEOCODER_TIMEOUT']=  "5"
  Oneclick::Application.config.enable_feedback = true
  Oneclick::Application.config.traveler_read_all_organization_feedback = false
  Oneclick::Application.config.agent_read_feedback = false
  Oneclick::Application.config.provider_read_all_feedback = false
  Oneclick::Application.config.tripless_feedback = false
  honeybadger_api_key = 'f49faffa'
  Oneclick::Application.config.poi_file = 'db/pa/pa-poi-from-arcgis.csv'
  Oneclick::Application.config.default_county = 'York'
  Oneclick::Application.config.state = 'PA'

  Oneclick::Application.config.max_walk_seconds = 3600

  ##Ecolane Variables
  Oneclick::Application.config.ecolane_system_id = "ococtest"
  Oneclick::Application.config.ecolane_x_ecolane_token = ENV['X_ECOLANE_TOKEN']
  Oneclick::Application.config.ecolane_base_url = "https://rabbit-test.ecolane.com"


when 'jta'
  Oneclick::Application.config.host = 'oneclick-jta.camsys-apps.com'
  Oneclick::Application.config.ui_logo = 'jta/TransPortalLogo-original.jpg'
  Oneclick::Application.config.geocoder_components = 'administrative_area:FL|country:US'
  # TODO Do we maybe need different bounds for kiosk vs. default?
  Oneclick::Application.config.map_bounds      = [[30.0668986565,-82.0920740215],[30.5909384888,-81.319458582]]
  Oneclick::Application.config.geocoder_bounds = [[30.0668986565,-82.0920740215],[30.5909384888,-81.319458582]]
  Oneclick::Application.config.default_zoom = 12
  Oneclick::Application.config.open_trip_planner = "http://otpv1-jta.camsys-apps.com:8080/otp/routers/jta/plan?"
  Oneclick::Application.config.taxi_fare_finder_api_key = "SIefr5akieS5"
  Oneclick::Application.config.taxi_fare_finder_api_city = "Jacksonville-FL"
  Oneclick::Application.config.name = '1-Click/JTA'
  ENV['SMTP_MAIL_USER_NAME'] = "oneclick.pa.camsys" # TODO
  ENV['SMTP_MAIL_PASSWORD'] = "CatDogMonkey" # TODO
  ENV['SYSTEM_SEND_FROM_ADDRESS'] = "donotreply@rabbittransit.org" # TODO
  ENV['SEND_FEEDBACK_TO_ADDRESS'] = "Oneclick@Camsys.com" # TODO
  ENV['GOOGLE_GEOCODER_ACCOUNT']=  "gme-cambridgesystematics"
  ENV['GOOGLE_GEOCODER_KEY']=      "dXP8tsyrLYECMWGxgs5LA9Li0MU="
  ENV['GOOGLE_GEOCODER_CHANNEL']=  "ARC_ONECLICK"
  ENV['GOOGLE_GEOCODER_TIMEOUT']=  "5"
  Oneclick::Application.config.enable_feedback = true
  Oneclick::Application.config.traveler_read_all_organization_feedback = true
  Oneclick::Application.config.agent_read_feedback = true
  Oneclick::Application.config.provider_read_all_feedback = true
  Oneclick::Application.config.tripless_feedback = false
  honeybadger_api_key = 'f49faffa'
  Oneclick::Application.config.poi_file = 'db/pa/pa-poi-from-arcgis.csv' # TODO
  Oneclick::Application.config.default_county = 'Duval'
  Oneclick::Application.config.state = 'FL'

  Oneclick::Application.config.max_walk_seconds = 3600

end

case Oneclick::Application.config.ui_mode
when 'desktop'
  Oneclick::Application.config.google_place_search = 'geocode'
when 'kiosk'
  Oneclick::Application.config.google_place_search = 'places'
else
  raise "UI mode #{Oneclick::Application.config.ui_mode} not supported."
end

# # SMTP Mail Sender Account
ENV['SMTP_MAIL_ADDR'] =           "smtp.gmail.com"
ENV['SMTP_MAIL_PORT'] =           "587"
ENV['SMTP_MAIL_DOMAIN'] =         "gmail.com"
ENV['SMTP_MAIL_USER_NAME'] =      "oneclick.arc.camsys"
ENV['SMTP_MAIL_PASSWORD'] =       "CatDogMonkey"

Honeybadger.configure do |config|
  config.api_key = honeybadger_api_key
  # Uncomment this if you want to send honeybadger notices from development:
  # config.development_environments = ['test', 'cucumber']
end

# General UI configuration settings
Oneclick::Application.config.ui_typeahead_delay = 300       # milliseconds delay between keystrokes before a query is sent to the server to retrieve a typeahead list
Oneclick::Application.config.ui_typeahead_min_chars = 4     # minimum number of characters to initiate a query
Oneclick::Application.config.ui_typeahead_list_length = 10  # max number of items displayed in the typeahead list
Oneclick::Application.config.ui_search_poi_items = 10       # max number of matching POIs to return in a search
Oneclick::Application.config.ui_min_geocode_chars = 5       # Minimum number of characters (not including whitespace) before sending to the geocoder

Oneclick::Application.config.address_cache_expire_seconds = 3600 # seconds to keep addresses returned from the geocoder in the cache
Oneclick::Application.config.return_trip_delay_mins = 120   # minutes needed at last trip place before scheduling the return trip
Oneclick::Application.config.trip_time_ahead_mins = 15      # minutes ahead of now to default the start time to for new trips

# Note that as of 2014-06-04, at least, these timeouts are only used by rideshare.
Oneclick::Application.config.remote_read_timeout_seconds = 10    # seconds to wait before timing out reading a page through a web request
Oneclick::Application.config.remote_request_timeout_seconds = 10 # seconds to wait for a remote web site/api to respond to a request

ROLES = [
  'System Administrator',
  'Agency Administrator',
  'Agency Agent',
  'Provider Staff'
]

Oneclick::Application.config.session_timeout       = ENV['SESSION_TIMEOUT']
Oneclick::Application.config.session_alert_timeout = ENV['SESSION_ALERT_TIMEOUT']

# See https://github.com/mojombo/chronic#time-zones
Chronic.time_class = Time.zone

class String
  def to_sample_email suffix
    downcase.gsub(/[^a-z\s]/, '').gsub(/\s/, '_') + '_' + suffix + '@camsys.com'
  end
end

