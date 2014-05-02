class ServiceCoverageMap < ActiveRecord::Base

  attr_accessor :keep_record
  
  #associations
  belongs_to :service
  belongs_to :geo_coverage

  # attr_accessible :service, :geo_coverage, :service_id, :geo_coverage_id, :rule

  scope :type_polygon, -> {self.joins(:geo_coverage).where("coverage_type = ?", "polygon")}

end
