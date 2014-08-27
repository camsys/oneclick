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

  config.i18n.fallbacks = true

  config.active_support.deprecation = :notify

  case ENV['BRAND'] || 'arc'
    when 'arc'
      config.action_mailer.default_url_options = { :host => 'oneclick-arc.camsys-apps.com' }
    when 'pa'
      config.action_mailer.default_url_options = { :host => 'oneclick-pa.camsys-apps.com' }
    when 'broward'
      config.action_mailer.default_url_options = { :host => 'oneclick-broward.camsys-apps.com' }
    when 'jta'
      config.action_mailer.default_url_options = { :host => 'oneclick-jta.camsys-apps.com' }
    when 'ieuw'
      config.action_mailer.default_url_options = { :host => 'oneclick-ieuw.camsys-apps.com' }
    else
      raise "Brand #{ENV['BRAND']} not handled"
  end

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
