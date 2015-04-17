require 'date'

module Reporting::ReportHelper

  # include both generic reports and customized reports
  def all_report_infos
    
    query_hash = {}

    role_check = report_by_user_role_query_string

    if role_check
      generic_report_infos = Reporting::ReportingReport.where(role_check).map {
        |report|
          {
            id: report.id,
            name: report.name,
            is_generic: true
          }
      }
    else
      # current user cannot see ad-hoc reports
      generic_report_infos = []
    end

    customized_report_infos = Report.all.map {
      |report|
        {
          id: report.id,
          name: report.name,
          is_generic: false
        }
    }

    (generic_report_infos + customized_report_infos).sort_by {|r| r[:name]}
  end

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

  def filter_lookup_table_data(lookup_table)
    return nil if !lookup_table

    data = lookup_table.data_model.order(lookup_table.display_field_name.to_sym)

    data_access_type = lookup_table.data_access_type

    is_sys_admin = current_user.has_role?(:system_administrator) || current_user.has_role?(:admin) 
    
    unless is_sys_admin || data_access_type.blank? || 
      lookup_table.data_model.columns_hash.keys.index(lookup_table.id_field_name).nil?

      # double quote in case field_name is in uppercase
      field_name = "\"#{lookup_table.id_field_name}\""

      is_provider_staff = current_user.has_role?(:provider_staff, :any)
      is_agency_admin = current_user.has_role?(:agency_administrator, :any)
      is_agent = current_user.has_role?(:agent, :any)

      if data_access_type.to_sym == :provider && is_provider_staff
        access_id = current_user.provider.id rescue nil
        data = data.where("#{field_name} = ?" , access_id) 
      elsif data_access_type.to_sym == :agency && (is_agency_admin || is_agent)
        access_id = current_user.agency.id rescue nil
        data = data.where("#{field_name} = ?" , access_id) 
      elsif data_access_type.to_sym == :service && is_provider_staff
        access_id = current_user.provider.services.pluck(:id) rescue []
        if access_id.count <=1
          data = data.where("#{field_name} = ?" , access_id) 
        else
          data = data.where("#{field_name} in (?)" , access_id) 
        end
      end
    end

    data
  end

  private

  def report_by_user_role_query_string
    is_sys_admin = current_user.has_role?(:system_administrator) || current_user.has_role?(:admin) 
    is_provider_staff = current_user.has_role?(:provider_staff, :any)
    is_agency_admin = current_user.has_role?(:agency_administrator, :any)
    is_agent = current_user.has_role?(:agent, :any)

    # needs to use arel in order to have a OR query chain
    reports_arel = Reporting::ReportingReport.arel_table
    
    # check each role
    sys_admin_role_check = (reports_arel[:is_sys_admin].eq(true)).or(reports_arel[:is_sys_admin].eq(nil)) if is_sys_admin
    provider_staff_role_check = (reports_arel[:is_provider_staff].eq(true)).or(reports_arel[:is_provider_staff].eq(nil)) if is_provider_staff
    agency_admin_role_check = (reports_arel[:is_agency_admin].eq(true)).or(reports_arel[:is_agency_admin].eq(nil)) if is_agency_admin
    agent_role_check = (reports_arel[:is_agent].eq(true)).or(reports_arel[:is_agent].eq(nil)) if is_agent

    # chain them together via OR
    role_check = sys_admin_role_check if is_sys_admin
    if is_provider_staff
      if role_check
        role_check = role_check.or provider_staff_role_check 
      else
        role_check = provider_staff_role_check
      end
    end

    if is_agency_admin
      if role_check
        role_check = role_check.or agency_admin_role_check 
      else
        role_check = agency_admin_role_check
      end
    end

    if is_agent
      if role_check
        role_check = role_check.or agent_role_check 
      else
        role_check = agent_role_check
      end
    end

    role_check
  end

end
