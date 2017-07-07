module Export
  class ExportApiController < ActionController::Base

    before_action :confirm_export_token

    def confirm_export_token
      unless ENV['EXPORT_TOKEN'] and params[:token] == ENV['EXPORT_TOKEN']
        render status: 403, json: 'INVALID EXPORT TOKEN'
      end
    end

  end
end
