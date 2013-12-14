# Check that we got loaded from application.yml

raise "Config not loaded from application.yml" unless ENV['ENV_FROM_APPLICATION_YML']

# use as Rails.application.config.brand
Oneclick::Application.config.brand = ENV['BRAND'] || 'arc'

# defaults for all brands
Oneclick::Application.config.enable_rideshare = false

case ENV['BRAND'] || 'arc'
  when 'arc'
  Oneclick::Application.config.ui_logo = 'arc/arc-logo.png'
  Oneclick::Application.config.geocoder_components = 'administrative_area:GA|country:US'
  Oneclick::Application.config.map_bounds = [[33.457797,-84.754028], [34.090199,-83.921814]]
  Oneclick::Application.config.geocoder_bounds = [[33.737147,-84.406634], [33.764125,-84.370361]]  
  Oneclick::Application.config.open_trip_planner = "http://arc-otp-2.camsys-apps.com"
  Oneclick::Application.config.taxi_fare_finder_api_key = "SIefr5akieS5"
  Oneclick::Application.config.taxi_fare_finder_api_city = "Atlanta"
  Oneclick::Application.config.enable_rideshare = true
  Oneclick::Application.config.name = 'ARC OneClick'

when 'broward'  
  Oneclick::Application.config.ui_logo = 'broward/Broward_211_Get_Connected_get_answers.jpg'
  Oneclick::Application.config.geocoder_components = 'administrative_area:FL|country:US'
  Oneclick::Application.config.map_bounds = [[26.427309, -80.347081], [25.602294, -80.061728]]
  Oneclick::Application.config.geocoder_bounds = [[26.427309, -80.347081], [25.602294, -80.061728]]
  Oneclick::Application.config.open_trip_planner = "http://arc-otp-demo.camsys-apps.com"
  Oneclick::Application.config.taxi_fare_finder_api_key = "SIefr5akieS5"
  Oneclick::Application.config.taxi_fare_finder_api_city = "Miami"
  Oneclick::Application.config.name = 'OneClick'

when 'pa'
  Oneclick::Application.config.ui_logo = 'pa/penndotLogo.jpg'
  Oneclick::Application.config.geocoder_components = 'administrative_area:PA|country:US'
  Oneclick::Application.config.map_bounds = [[41.970622, -80.461542], [39.734653, -75.007294]]
  Oneclick::Application.config.geocoder_bounds = [[41.970622, -80.461542], [39.734653, -75.007294]]
  Oneclick::Application.config.open_trip_planner = "http://oneclick-otp-yata.camsys-apps.com:8080"
  Oneclick::Application.config.taxi_fare_finder_api_key = "SIefr5akieS5"
  Oneclick::Application.config.taxi_fare_finder_api_city = "Harrisburg-PA"
  Oneclick::Application.config.name = '1-Click/PA'

end

# General UI configuration settings
Oneclick::Application.config.ui_typeahead_delay = 300       # milliseconds delay between keystrokes before a query is sent to the server to retrieve a typeahead list
Oneclick::Application.config.ui_typeahead_min_chars = 4     # minimum number of characters to initiate a query
Oneclick::Application.config.ui_typeahead_list_length = 10  # max number of items displayed in the typeahead list  
Oneclick::Application.config.ui_search_poi_items = 10       # max number of matching POIs to return in a search 
Oneclick::Application.config.ui_min_geocode_chars = 5       # Minimum number of characters (not including whitespace) before sending to the geocoder 

Oneclick::Application.config.address_cache_expire_seconds = 3600 # seconds to keep addresses returned from the geocoder in the cache
Oneclick::Application.config.return_trip_delay_mins = 120   # minutes needed at last trip place before scheduling the return trip
Oneclick::Application.config.trip_time_ahead_mins = 30      # minutes ahead of now to default the start time to for new trips

Oneclick::Application.config.remote_read_timeout_seconds = 5    # seconds to wait before timing out reading a page through a web request
Oneclick::Application.config.remote_request_timeout_seconds = 5 # seconds to wait for a remote web site/api to respond to a request
