module Reporting
  module Modelable
    extend ActiveSupport::Concern
    
    private 

    def make_a_reporting_model(model_class_name, table_name, primary_key = 'id')
      if !Object.const_defined?(model_class_name)
        klass = Class.new ActiveRecord::Base do 

          # configure table/view name
          self.table_name = table_name

          # configure primary_key
          self.primary_key = primary_key

          # model should be readonly (since this is a reporting tool)
          def readonly?
            true
          end

        end

        # configure new model name
        Reporting.const_set table_name.classify, klass
      end
    end
  end
end