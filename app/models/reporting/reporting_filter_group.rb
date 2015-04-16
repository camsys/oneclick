module Reporting
  class ReportingFilterGroup < ActiveRecord::Base
    has_many :reporting_filter_fields

    has_many :reporting_specifc_filter_groups
    has_many :reporting_reports, :through => :reporting_specifc_filter_groups

    validates :name, presence: true

  end
end
