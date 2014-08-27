Oneclick::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  config.cache_classes = false

  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  config.action_dispatch.best_standards_support = :builtin

  # development settings
  config.serve_static_assets = true
  config.assets.compress = false
  # config.assets.compile
  # config.assets.digest
  config.assets.debug = true

  # # QA settings
  # config.serve_static_assets = true
  # config.assets.compress = true
  # config.assets.compile = false
  # config.assets.digest = true
  # # config.assets.debug

  # config.i18n.fallbacks

  config.active_support.deprecation = :log

  config.action_mailer.default_url_options = { :host => 'localhost:3000' }

  config.action_mailer.delivery_method = :letter_opener
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.default :charset => "utf-8"

  config.log_level = :info
  config.eager_load = false
end
