require 'date'

module Reporting::ReportHelper

  # converts datetime format to MM/DD/YYYY (to be correctly displayed in front-end)
  def filter_value(raw_value, is_date_field)
    raw_value = Date.strptime(raw_value, "%Y-%m-%d").strftime("%m/%d/%Y") rescue '' if is_date_field
    raw_value || ''
  end

  # find out input type based on field type
  def filter_input_type(field_type)
    case field_type.to_sym
    when :primary_key, :integer, :float, :decimal
      'number'
    else
      'search'
    end
  end

  # format output field value if formatter is configured
  def format_output(raw_value, field_type, formatter)
    unless raw_value.blank? || field_type.blank?
      case field_type.to_sym
      when :date, :datetime
        if field_type == :date
          default_formatter = "%m/%d/%Y" 
        else
          default_formatter = "%m/%d/%Y %H:%M:%S"
        end

        formatter = default_formatter if formatter.blank?
        raw_value = raw_value.strftime(formatter) rescue raw_value.strftime(default_formatter)

      when :integer, :float, :decimal
        if !formatter.blank?
          case formatter.lowercase
          when 'currency'
            raw_value = number_with_currency(raw_value)
          when 'percentage'
            raw_value = number_with_percentage(raw_value)
          when 'delimiter'
            raw_value = number_with_delimiter(raw_value)
          end
        end

      end
    end

    raw_value
  end

end
