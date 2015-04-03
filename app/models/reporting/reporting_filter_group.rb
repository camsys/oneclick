module Reporting
  class ReportingFilterGroup < ActiveRecord::Base
    has_many :reporting_filter_fields

    validates :name, presence: true

  end
end
