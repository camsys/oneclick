class ServiceCoverageMap < ActiveRecord::Base

  #associations
  belongs_to :service
  belongs_to :geo_coverage

  attr_accessible :service, :geo_coverage, :service_id, :geo_coverage_id, :rule

end
