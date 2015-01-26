
  # defaults for all brands
  configs = [['enable_rideshare', false, "desc"],
  ['smtp_mail_addr', "smtp.gmail.com","desc"],  #ENV
  ['smtp_mail_port', 587,"desc"],             #ENV
  ['smtp_mail_domain', "gmail.com","desc"],    #ENV
  ['session_timeout', '10', "desc"],    #ENV
  ['session_alert_timeout', '30', "desc"],  #ENV
  ['default_zoom', nil, "desc"],
  ['max_offset_from_desired', nil, "desc"],
  ['default_min_duration' , 0 , "desc"],#minutes
  ['default_max_duration' , 120 , "desc"],#minutes
  ['default_min_transfers' , 0  , "desc"],
  ['default_max_transfers' , 2 , "desc"],
  ['default_min_fare' , 0 , "desc"],
  ['default_max_fare' , 50, "desc"],
  ['paratransit_duration_factor' , 2.0 , "desc"],
  ['minimum_paratransit_duration' , 2.hours, "desc"],
  ['rideshare_duration_factor' , 1.5, "desc"],
  ['minimum_rideshare_duration',(1.5).hours , "desc"],
  ['show_update_services' , false , "desc"],
  ['min_drive_seconds' , 180, "desc"],
  ['max_walk_seconds' , 1200, "desc"],
  ['allows_booking' , false, "desc"],
  ['street_view_url' , '/streetview.html', "desc"],
  ['enable_sidewalk_obstruction' ,true, "desc"],
  ['sidewalk_feedback_query_buffer',0.0001, "lat/lon degree"],
  ['initial_signup_question' ,false, "desc"],
  ['max_ui_duration' ,  2.hours, "desc"],
  ['min_ui_duration' , 1.hours, "desc"],
  ['google_places_api_key','AIzaSyCvKyNoBzQNrBRuSRkipWye0pdj__HjrmU', "desc"],
  ['time_zone' , 'Eastern Time (US & Canada)', "desc"],
  ['available_locales' ,[:en, :es], ""], # default      #i18n
  ['service_logo_format_list', '%w(jpg jpeg gif png)', "desc"],
  ['service_logo_dimensions' , [40, 40], ""],
  ['provider_logo_format_list', %w(jpg jpeg gif png), ""],
  ['provider_logo_dimensions', [40, 40], ""],
  ['host' ,'oneclick-arc.camsys-apps.com', "desc"],
  ['ui_logo' , 'arc/logo.png', "desc"],
  ['geocoder_components', 'administrative_area:GA|country:US', "desc"],
  ['map_bounds' , [[33.457797,-84.754028], [34.090199,-83.921814]], ""],
  ['geocoder_bounds',[[33.737147,-84.406634], [33.764125,-84.370361]], ""],
  ['open_trip_planner',  "http://otpv1-arc.camsys-apps.com:8080/otp/routers/atl/plan?", "desc"],
  ['transit_respects_ada' , false , "desc"],
  ['taxi_fare_finder_api_key', "SIefr5akieS5", "desc"],
  ['taxi_fare_finder_api_city' , "Atlanta", "desc"],
  ['enable_rideshare' , true, "desc"],
  ['name' , 'ARC 1-Click', "desc"],
  ['SMTP_MAIL_USER_NAME' , "oneclick.arc.camsys", "desc"],  #ENV
  ['SMTP_MAIL_PASSWORD' , "CatDogMonkey", "desc"],              #ENV
  ['SYSTEM_SEND_FROM_ADDRESS', "donotreply@atlantaregional.com" , "desc"], #ENV
  ['SEND_FEEDBACK_TO_ADDRESS',  "1-Click@camsys.com", "desc"],         #ENV
  ['GOOGLE_GEOCODER_ACCOUNT', "gme-cambridgesystematics", "desc"],   #ENV
  ['GOOGLE_GEOCODER_KEY', "dXP8tsyrLYECMWGxgs5LA9Li0MU=", "desc"],  #ENV
  ['GOOGLE_GEOCODER_CHANNEL', "ARC_ONECLICK", "desc"],               #ENV
  ['GOOGLE_GEOCODER_TIMEOUT',"5", "desc"],                  #ENV
  ['enable_feedback', true, "desc"],
  ['traveler_read_all_organization_feedback',true, "desc"],
  ['agent_read_feedback' ,true, "desc"],
  ['provider_read_all_feedback' ,true, "desc"],
  ['tripless_feedback' , false, "desc"],
  ['honeybadger_api_key' , 'ba642a71', "desc"],    #NO PREFIX
  ['poi_file' , 'db/arc_poi_data/CommFacil_20131015.txt', "desc"],
  ['show_update_services' ,  true, "desc"],
  ['default_county' , '' , "desc"],
  ['state' , 'GA', "desc"],
  ['ui_typeahead_delay', 300, "desc"],       # milliseconds delay between keystrokes before a query is sent to the server to retrieve a typeahead list
  ['ui_typeahead_min_chars', 4 , "desc"],    # minimum number of characters to initiate a query
  ['ui_typeahead_list_length', 10, "desc"],  # max number of items displayed in the typeahead list
  ['ui_search_poi_items', 10 , "desc"],      # max number of matching POIs to return in a search
  ['ui_min_geocode_chars' , 5 , "desc"],      # Minimum number of characters (not including whitespace) before sending to the geocoder
  ['address_cache_expire_seconds' , 3600 , "desc"],# seconds to keep addresses returned from the geocoder in the cache
  ['return_trip_delay_mins', 120 , "desc"],  # minutes needed at last trip place before scheduling the return trip
  ['trip_time_ahead_mins', 15 , "desc"],    #interval: This is not used as the default trip ahead time.  It is used as the interval (which is actually ignored by the front-end)
  ['default_trip_ahead_mins', 120, "desc"],    #How many minutes into the future should the default outbound trip time be? (It is rounded to the next 15 min interval)
  ['config.remote_read_timeout_seconds', 10, "desc"],    # seconds to wait before timing out reading a page through a web request
  ['config.remote_request_timeout_seconds', 10 , "desc"],# seconds to wait for a remote web site/api to respond to a request
  ['translation_tag_locale_text', 'Tags', "desc"]
  ['service_max_allow_advanced_book_days', 365, "desc"]]

  puts "Initializing Configs"
  configs.each do |config|
    puts config[0] + " = " + config[1].to_s
    new_config = OneclickConfiguration.where(code: config[0]).first_or_create
    new_config.value = config[1]
    new_config.description = config[2]
    new_config.save
  end
