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
  def format_output(raw_value, field_type, formatter = nil, formatter_option = nil)
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
        formatter_precision = formatter_option.to_i rescue nil if !formatter_option.blank?
        formatter_precision = nil if formatter_precision && formatter_precision < 0 # ignore illegal value
        if !formatter.blank?
          case formatter.lowercase
          when 'currency'
            formatter_precision = 2 if formatter_precision.nil?
            raw_value = number_to_currency(raw_value, precision: formatter_precision)
          when 'percentage'
            formatter_precision = 3 if formatter_precision.nil?
            raw_value = number_to_percentage(raw_value, precision: formatter_precision)
          when 'delimiter'
            raw_value = number_with_precision(raw_value, precision: formatter_precision) if formatter_precision
            raw_value = number_with_delimiter(raw_value)
          when 'phone'
            raw_value = number_to_phone(raw_value)
          when 'human'
            formatter_precision = 3 if formatter_precision.nil?
            raw_value = number_to_human(raw_value, precision: formatter_precision)
          when 'precision'
            formatter_precision = 3 if formatter_precision.nil?
            raw_value = number_with_precision(raw_value, precision: formatter_precision)
          end
        end

      end
    end

    raw_value
  end

end
