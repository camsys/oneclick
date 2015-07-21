Oneclick::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  config.cache_classes = true

  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # config.action_dispatch.best_standards_support

  config.serve_static_assets = true

  config.assets.compress = true
  config.assets.compile = false
  config.assets.digest = true
  # config.assets.debug

  config.i18n.fallbacks = false

  config.active_support.deprecation = :notify

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default :charset => "utf-8"

  # Warning: Heroku uses env var LOG_LEVEL
  config.log_level = :info
  # For Heroku; see https://devcenter.heroku.com/articles/logging#writing-to-your-log
  config.logger = Logger.new(STDOUT)

  config.eager_load = true
end
