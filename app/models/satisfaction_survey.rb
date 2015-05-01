class SatisfactionSurvey < ActiveRecord::Base
  belongs_to :trip
  serialize :reasoning, Array

  def self.enabled?
    Oneclick::Application.config.enable_satisfaction_surveys
  end
end
