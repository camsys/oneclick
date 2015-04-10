module Reporting
  class ReportingFilterField < ActiveRecord::Base
    belongs_to :reporting_report
    belongs_to :reporting_filter_group
    belongs_to :reporting_filter_type
    belongs_to :reporting_lookup_table

    validates :reporting_report, presence: true
    validates :reporting_filter_group, presence: true
    validates :reporting_filter_type, presence: true
    validates :name, presence: true
    validates :sort_order, presence: true

    # field associated custom ransacker (base search unit)
    # TODO: probably no need
    def ransacker
      # if lookup_table
      #   report_data_model = Object.const_get(report.data_model_class_name)

      #   if report_data_model
      #     report_data_model.ransacker name.to_sym do |parent|
      #       Arel.sql("#{lookup_table.name}.#{lookup_table.id}")
      #     end
      #   end
      # end
    end
  end
end
