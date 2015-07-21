module Reporting
  class ReportingSpecificFilterGroup < ActiveRecord::Base
    belongs_to :reporting_report
    belongs_to :reporting_filter_group
  end
end
