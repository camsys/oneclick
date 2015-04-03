module Reporting
  class ReportingReport < ActiveRecord::Base
    include Reporting::Modelable

    has_many :reporting_filter_fields
    has_many :reporting_output_fields

    validates :name, presence: true, :uniqueness => true
    validates :data_source, presence: true, :uniqueness => true

    # model name is based on table name
    def data_model_class_name
      "Reporting::#{data_source.classify}"
    end

    def data_model
      define_data_model
    end

    # include both generic reports and customized reports
    def self.all_report_infos
      generic_reports = ReportingReport.all.map {
        |report|
          {
            id: report.id,
            name: report.name,
            is_generic: true
          }
      }

      customized_reports = Report.all.map {
        |report|
          {
            id: report.id,
            name: report.name,
            is_generic: false
          }
      }

      (generic_reports + customized_reports).sort_by {|r| r[:name]}
    end

    private

    # define new model for the tables not known to AR
    def define_data_model

      # call modelable module method
      make_a_reporting_model data_model_class_name, data_source

      # make sure data_model can export as csv
      reporting_model = Object.const_get data_model_class_name
      enable_csv_export_on_data_model reporting_model

      # define customized ransackers
      reporting_filter_fields.each do |field|
        field.ransacker
      end

      # return defined model
      reporting_model

    end

    # enable to_csv on each newly created reporting_data_model
    def enable_csv_export_on_data_model(reporting_model)

      if reporting_model

        reporting_model.class_exec {

          def self.to_csv(options = {})

            # figure out output field names and columns
            output_field_names = []
            output_field_titles = []
            # if output_fields is empty, then use column_names instead
            report = Reporting::ReportingReport.where(data_source: self.table_name).first
            output_fields = report.reporting_output_fields rescue []

            if output_fields.blank?
              output_field_names = self.column_names
              output_field_titles = output_field_names
            else
              output_fields.each do |field|
                output_field_names << field.name
                output_field_titles << field.title.blank? ? field.name : field.title
              end
            end

            CSV.generate(options) do |csv|
              csv << output_field_titles
              all.each do |row|
                csv << row.attributes.values_at(*output_field_names)
              end
            end

          end

        }
      end

    end

  end
end
