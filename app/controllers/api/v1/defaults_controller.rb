module Api
  module V1
    class DefaultsController < Api::V1::ApiController

        def index
            render json: Oneclick::Application.config.send(self.code)
        end

        def create
            oc = OneclickConfiguration.where(code: self.code).first_or_initialize
            oc.value = params["data"].to_json
            oc.save
            render json: {status: 200, message: "Success"}
        end

        def code
            (params[:type] == "internal") ? "otp_internal_defaults_json" : "otp_external_defaults_json"
        end
   
    end
  end
end