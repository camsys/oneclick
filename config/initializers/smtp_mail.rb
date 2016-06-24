
ActionMailer::Base.smtp_settings = {
  :address              => Oneclick::Application.config.smtp_mail_addr,
  :port                 => Oneclick::Application.config.smtp_mail_port,
  :domain               => Oneclick::Application.config.smtp_mail_domain,
  :user_name            => Oneclick::Application.config.smtp_mail_user_name,
  :password             => Oneclick::Application.config.smtp_mail_password,
  :authentication       => 'plain',
  :enable_starttls_auto => 'true'
}
