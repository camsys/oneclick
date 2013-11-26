Oneclick::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  config.cache_classes = false

  config.whiny_nils = true

  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  config.action_dispatch.best_standards_support = :builtin
  config.active_record.mass_assignment_sanitizer = :strict
  config.active_record.auto_explain_threshold_in_seconds = 0.5

  # config.serve_static_assets

  config.assets.compress = false
  # config.assets.compile
  # config.assets.digest
  config.assets.debug = true

  # config.i18n.fallbacks

  config.active_support.deprecation = :log

  config.action_mailer.default_url_options = { :host => 'localhost:3000' }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.perform_deliveries = false
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.default :charset => "utf-8"

  config.log_level = :info
end
