class SatisfactionSurvey < ActiveRecord::Base
  belongs_to :trip

  def self.enabled?
    Oneclick::Application.config.enable_satisfaction_surveys
  end
end
