require File.expand_path('../boot', __FILE__)

require 'csv'
require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

# This is for when we are talking to a postgis database on heroku
if ENV['HEROKU']
  class ActiveRecordOverrideRailtie < Rails::Railtie
    initializer "active_record.initialize_database.override" do |app|

      ActiveSupport.on_load(:active_record) do
        if url = ENV['DATABASE_URL']
          ActiveRecord::Base.connection_pool.disconnect!
          parsed_url = URI.parse(url)
          config =  {
              adapter:             'postgis',
              host:                parsed_url.host,
              encoding:            'unicode',
              database:            parsed_url.path.split("/")[-1],
              port:                parsed_url.port,
              username:            parsed_url.user,
              password:            parsed_url.password
          }
          ActiveRecord::Base.establish_connection(config)
        end
      end
    end
  end
end

if ENV['GC_PROFILER_ENABLE']
  puts "+-----------------------+"
  puts "| ENABLING GC::Profiler |"
  puts "+-----------------------+"
  GC::Profiler.enable
end

module Oneclick
  class Application < Rails::Application

    # don't generate RSpec tests for views and helpers
    config.generators do |g|

      g.test_framework :rspec, fixture: true
      g.fixture_replacement :factory_girl, dir: 'spec/factories'

      g.view_specs false
      g.helper_specs false
    end

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)
    config.autoload_paths += %W(#{config.root}/lib)

    config.autoload_paths += %W(#{Rails.root}/app/reports)
    config.autoload_paths += %W(#{Rails.root}/app/services)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = ENV['TIME_ZONE'] || "Eastern Time (US & Canada)"

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.enforce_available_locales = false
    config.i18n.default_locale = :en

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password, :password_confirmation]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    # Enable the asset pipeline
    config.assets.enabled = true
    # For heroku; see http://blog.nathanhumbert.com/2012/01/rails-32-on-heroku-tip.html
    config.assets.initialize_on_precompile = false

    config.ui_mode = ENV['UI_MODE'] || 'desktop'

    # config.assets.precompile = ['foo']

    if config.ui_mode=='desktop'
      config.assets.paths << File.join(Rails.root, 'app', 'assets-default')
    config.assets.precompile += %w(
        application.css
        arc.css
        pa.css
        broward.css
        tadaaapickr.en.js
        typeahead.js-bootstrap.css
        users.css
    )
    else # config.ui_mode=='kiosk'
      config.assets.paths << File.join(Rails.root, 'app', 'assets-kiosk')
      config.assets.precompile += %w(
        application.css
        _base.css
        style.css
        pa.css
        ext/fontawesome-ext-webfont.eot
        ext/fontawesome-ext-webfont.svg
        ext/fontawesome-ext-webfont.ttf
        ext/fontawesome-ext-webfont.woff
      )
    end

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.6'

    # See http://work.stevegrossi.com/2013/04/06/dynamic-error-pages-with-rails-3-2/
    config.exceptions_app = self.routes
    config.brand = ENV['BRAND'] || 'arc'
    config.ui_mode = ENV['UI_MODE'] || 'desktop'
    if config.ui_mode=='desktop'
      config.sass.load_paths << File.expand_path("./app/assets-default/stylesheets/#{config.brand}")
      if ENV['USE_GOOGLE_ANALYTICS'].to_s.downcase == 'true'
        config.sass.load_paths << File.expand_path("./app/assets-default/javascripts/#{config.brand}")
      end
    else # config.ui_mode=='kiosk'
      config.sass.load_paths << File.expand_path("./app/assets-kiosk/stylesheets/#{config.brand}")
    end
  end

end

def oneclick_available_locales
  begin
    s = '(' + (I18n.available_locales + [:tags]).join('|') + ')'
    %r{#{s}}
  rescue Exception => e
    Rails.logger.info "Exception #{e.message} during oneclick_available_locales"
    puts "Exception #{e.message} during oneclick_available_locales"
    %r{en}
  end
end

