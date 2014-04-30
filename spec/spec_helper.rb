ENV["RAILS_ENV"] ||= 'test'

require 'simplecov'
SimpleCov.command_name 'rspec'

# This file is copied to spec/ when you run 'rails generate rspec:install'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'email_spec'
require 'rspec/autorun'
require 'capybara/rspec'
require 'awesome_print'
require 'factory_girl_rails'

I18n.locale = :en

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.include(EmailSpec::Helpers)
  config.include(EmailSpec::Matchers)

  config.include FactoryGirl::Syntax::Methods

  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"
  
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    # DatabaseCleaner.strategy = :truncation, {except: %w{traveler_characteristics traveler_accommodations
    #   service_types trip_purposes providers services schedules service_trip_purpose_maps
    #   service_characteristics
    #   service_accommodations
    #   user_accommodations
    #   user_characteristics
    #   }}
    DatabaseCleaner.start
  end

  config.before(:each) do
  end

  config.after(:each) do
    I18n.locale = :en
  end

  config.after(:suite) do
    DatabaseCleaner.clean
  end
end
