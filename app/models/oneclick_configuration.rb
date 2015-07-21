class OneclickConfiguration < ActiveRecord::Base

  serialize :value

  def self.create_or_update(code, value)
    config = OneclickConfiguration.where(code: code).first_or_create
    config.value = value
    Oneclick::Application.config.send "#{code}=", value

    config.save
  end

end
