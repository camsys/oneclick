module Reporting
  class ReportingOutputField < ActiveRecord::Base
    belongs_to :reporting_report

    validates :name, presence: true
    validates :reporting_report, presence: true
    validates :numeric_precision, :numericality => { :greater_than_or_equal_to => 0 }

  end
end
