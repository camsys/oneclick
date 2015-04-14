module Reporting
  class ReportingFilterGroup < ActiveRecord::Base
    belongs_to :reporting_report
    has_many :reporting_filter_fields

    validates :reporting_report, presence: true
    validates :name, presence: true

  end
end
