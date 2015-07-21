module Reporting
  class ReportingLookupTable < ActiveRecord::Base
    include Reporting::Modelable
    
    has_many :reporting_filter_fields

    validates :name, presence: true, :uniqueness => true
    validates :id_field_name, presence: true

    # model name is based on table name
    def data_model_class_name
      "Reporting::#{name.classify}"
    end

    def data_model
      define_data_model name
    end

    private

    # define new model for the tables not known to AR
    def define_data_model(table_name)

      # call modelable module method
      make_a_reporting_model(data_model_class_name, table_name)

      # return defined model
      Object.const_get data_model_class_name
    end
  end
end
