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

    private

    # define new model for the tables not known to AR
    def define_data_model

      # call modelable module method
      make_a_reporting_model data_model_class_name, data_source

      # define customized ransackers
      reporting_filter_fields.each do |field|
        field.ransacker
      end

      # return defined model
      Object.const_get data_model_class_name

    end

  end
end
