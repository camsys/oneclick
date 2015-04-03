module Reporting
  class ReportingOutputField < ActiveRecord::Base
    belongs_to :reporting_report

    validates :name, presence: true
    validates :reporting_report, presence: true

  end
end
