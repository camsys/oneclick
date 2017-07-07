module export

  class ExportApiController < ActionController::Base

    before_action :confirm_export_token

    def characteristics
      render json: {message: "fart"}
    end

    def confirm_export_token
      true
    end

  end
end
