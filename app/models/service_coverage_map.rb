class ServiceCoverageMap < ActiveRecord::Base

  #associations
  belongs_to :service
  belongs_to :coverage

  attr_accessible :service, :coverage, :service_id, :coverage_id, :rule

  # attr_accessible :title, :body
end
