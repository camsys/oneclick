require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

# TODO This is for when we are talking to a postgis database
# class ActiveRecordOverrideRailtie < Rails::Railtie
#   initializer "active_record.initialize_database.override" do |app|

#     ActiveSupport.on_load(:active_record) do
#       if url = ENV['DATABASE_URL']
#         ActiveRecord::Base.connection_pool.disconnect!
#         parsed_url = URI.parse(url)
#         config =  {
#             adapter:             'postgis',
#             host:                parsed_url.host,
#             encoding:            'unicode',
#             database:            parsed_url.path.split("/")[-1],
#             port:                parsed_url.port,
#             username:            parsed_url.user,
#             password:            parsed_url.password
#         }
#         establish_connection(config)
#       end
#     end
#   end
# end

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

    # add the reports folder to the list of classes to be autoloaded
    config.autoload_paths += %W(#{Rails.root}/app/reports)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Eastern Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
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

    # because application.css.scss only uses @import, not require, we need to make
    # sure all stylesheets are precompiled for the asset pipeline
    stylesheets = Dir.glob(File.join('app', 'assets', 'stylesheets', '**', '*')).map {
        |d| d.gsub(%r{app/assets/stylesheets/}, '')
        }.map {|d| d.gsub(%r{\.scss$}, '')}
        .select{|d| d =~ %r{\.css}} - ["application.css"]
    config.assets.precompile += stylesheets

    config.assets.precompile += %w(
      tadaaapickr.pack.min.js
      kiosk/_base.css
      kiosk/style.css
      trips.css
      trips.js
      home.css
    )

    config.assets.paths << Rails.root.join('app', 'assets', 'fonts')

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.3'

    # See http://work.stevegrossi.com/2013/04/06/dynamic-error-pages-with-rails-3-2/
    config.exceptions_app = self.routes
  end
end


