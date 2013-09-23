Geocoder.configure(

  # geocoding service (see below for supported options):
  :lookup => :google_premier,

  # to use an API key:
  :api_key => [ENV["GOOGLE_GEOCODER_KEY"], ENV["GOOGLE_GEOCODER_ACCOUNT"], ENV["GOOGLE_GEOCODER_CHANNEL"]],

  # geocoding service request timeout, in seconds (default 3):
  :timeout => ENV["GOOGLE_GEOCODER_TIMEOUT"].to_i,

  # set default units to kilometers:
  :units => :mi

  # caching (see below for details):
  #:cache => Redis.new,
  #:cache_prefix => "..."

)
