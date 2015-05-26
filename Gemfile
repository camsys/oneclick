source 'https://rubygems.org'
ruby '2.1.1'

gem 'rails', '4.0.3'

gem 'sprockets', '2.11.0'
# gem 'sass-rails', '~> 4.0.3'
gem 'sass-rails', github: 'camsys/sass-rails', tag: 'v4.0.3a'

unless ENV['UI_MODE']=='kiosk'
  gem 'bootstrap-sass', github: 'camsys/bootstrap-sass', tag: '3.2.0.CS.2'
  gem 'simple_form', '~> 3.1.0.rc1', github: 'camsys/simple_form', branch: 'cs-3.0'
else
  gem 'bootstrap-sass', '~> 2.3.2.0'
  gem 'simple_form', '3.0.1'
end

gem 'translation_engine', path: '~/code/translation_engine'
#gem 'translation_engine', github: 'camsys/translation_engine'

gem 'fog'
gem 'coffee-rails'
gem 'uglifier', '>= 1.0.3'
gem 'bootstrap-combobox'
gem 'jquery-rails'
gem 'cancan'
gem 'devise'
gem 'figaro'
gem 'geocoder'
gem 'haml-rails'
gem 'pg'
gem 'rolify'
gem 'thin'
gem 'puma'
gem "rack-timeout"
gem 'awesome_print'
gem 'chronic'
gem 'mechanize'
gem 'activemodel'
gem 'newrelic_rpm'
gem 'polylines'
gem 'activemdb'
gem 'ajaxful_rating', '>= 3.0.0.beta7'
gem 'honeybadger'
gem 'draper'
gem 'rubyzip'
gem 'lorem-ipsum-me'
gem 'faraday_middleware'
gem 'twilio-ruby'
gem 'rails_12factor', group: [:integration, :production, :qa, :staging]
gem 'font-awesome-rails'
gem 'twitter-typeahead-rails', github: 'camsys/twitter-typeahead-rails'
gem 'handlebars_assets'
gem 'simple_token_authentication'
gem 'Indirizzo'
gem 'momentjs-rails', '~> 2.5.0'
gem 'bootstrap3-datetimepicker-rails', '= 3.0.0.0'
gem 'active_model_serializers'
gem 'jquery-datatables-rails', '~> 2.1.10.0.2'
gem 'ajax-datatables-rails', '> 0.1.2'
gem 'active_attr'
gem 'twitter-bootstrap-rails-confirm', github: 'bluerail/twitter-bootstrap-rails-confirm', branch: 'bootstrap3'
gem 'activerecord-postgis-adapter', '= 1.1.0'
gem 'rgeo-activerecord'
gem 'rgeo'
gem 'rgeo-shapefile'
gem 'leaflet-rails', github: 'camsys/leaflet-rails'
gem 'mini_magick'
gem 'carrierwave'
gem 'poltergeist'
gem 'sidekiq'
gem 'ransack', github: 'camsys/ransack'
gem 'kaminari'
gem 'bootstrap-kaminari-views'
gem 'browser'
gem 'remotipart', '~> 1.2'

group :development do
  # gem 'ffi-geos'
  #gem 'mysql2'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'guard', '~> 1.8.3'
  gem 'guard-bundler'
  gem 'guard-cucumber'
  gem 'guard-rails'
  gem 'guard-rspec'
  gem 'guard-puma'
  gem 'pry-byebug'
  gem 'html2haml'
  gem 'quiet_assets'
  gem 'listen'
  gem 'rb-fchange', :require=>false
  gem 'rb-fsevent', :require=>false
  gem 'rb-inotify', :require=>false
  gem 'sextant'
  gem 'rails-erd'
  gem 'growl'
  gem 'travis'
  gem "letter_opener"
  gem 'yard'
  gem 'RedCloth' # Needed by yard
  gem 'foreman'
  # For sidekiq monitoring
  gem 'sinatra', :require => nil
  gem 'seed_dump'
end

group :development, :test do
  gem 'factory_girl_rails'
end

group :test do
  gem 'rspec-core', '~> 2.14.0'
  gem 'rspec-rails'
  gem 'capybara'
  gem 'cucumber-rails', :require=>false
  gem 'database_cleaner'
  gem 'email_spec'
  gem 'launchy'
  gem 'coveralls', require: false
  gem 'simplecov', require: false
  gem 'timecop'
end

