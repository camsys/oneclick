module Reporting
  class ResultsController < ApplicationController
    include ReportHelper

    before_action :verify_permission

    def index
      q_param = params[:q]
      page = params[:page]
      @per_page = params[:per_page] || Kaminari.config.default_per_page

      @report = ReportingReport.find params[:report_id]
      @q = @report.data_model.ransack q_param
      @params = {q: q_param}

      begin
        # list all output fields
        # if output_fields is empty, then export all columns in this table
        @fields = @report.reporting_output_fields.blank? ?
          @report.data_model.column_names.map{
            |x| {
              name: x 
            }
          } : @report.reporting_output_fields

        # total_results is for exporting
        total_results = @q.result(:district => true)

        # filter data based on accessibility
        total_results = filter_data(total_results)
        
        # @results is for html display; only render current page
        @results = total_results.order(:id)  if !@report.data_model.columns_hash.keys.index("id").nil?
        @results = total_results.page(page).per(@per_page)

        # this is used to test if any sql exception is triggered in querying
        # commen errors: table not found
        first_result = @results.limit(1) 

      rescue => e
        # error message handling
        total_results = []
        @results = []
      end

      respond_to do |format|
        format.html
        # format.csv { send_data total_results.to_csv }
        format.csv do
          send_data get_csv(total_results, @fields),
                filename: "#{@report.name.underscore}.csv", type: :text
        end
      end

    end

    private

    def verify_permission
      authorize! :access, :admin_reports
    end

    def filter_data(results)
      # data access filtering 
      # either filter by provider_id or agency_id
      unless current_user.has_role?(:system_administrator) || current_user.has_role?(:admin) 

         Reporting::ReportingFilterField.includes(:reporting_lookup_table)
          .where(reporting_filter_group_id: @report.reporting_filter_groups.pluck(:id).uniq).each do |field|
            
          data_access_type = field.reporting_lookup_table.data_access_type if field.reporting_lookup_table
          unless data_access_type.blank? || @report.data_model.columns_hash.keys.index(field.name).nil?
            
            field_name =  "\"#{field.name}\""

            if data_access_type.to_sym == :provider
              access_id = current_user.provider.id rescue nil
              results = results.where("#{field_name} = ?" , access_id)
            elsif data_access_type.to_sym == :agency
              access_id = current_user.agency.id rescue nil
              results = results.where("#{field_name} = ?" , access_id)
            elsif data_access_type.to_sym == :service
              access_id = current_user.provider.services.pluck(:id) rescue []
              if access_id.count <= 1
                results = results.where("#{field_name} = ?" , access_id)
              else
                results = results.where("#{field_name} in (?)" , access_id)
              end
            end

          end
           
         end
      end

      results
    end

    def get_csv(data, fields)
      # Excel is stupid if the first two characters of a csv file are "ID". Necessary to
      # escape it. https://support.microsoft.com/kb/215591/EN-US
      CSV.generate do |csv|
        headers = []
        fields.each do |field|
          headers << (field[:title].blank? ? field[:name] : field[:title])
        end

        if headers[0].start_with? "ID"
          headers = Array.new(headers)
          headers[0] = "'" + headers[0]
        end

        csv << headers

        if data.each do |row|
            csv << fields.map {|field| format_output row.send(field[:name]), 
              @report.data_model.columns_hash[field[:name].to_s].type,  
              field[:formatter]
            }
          end
        end
      end
    end

  end
end
