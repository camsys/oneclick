module Api
  module V1
    class DefaultsController < Api::V1::ApiController

        def index
            render json: Oneclick::Application.config.otp_defaults_json
        end

        def create
            oc = OneclickConfiguration.first_or_initialize(code: "otp_defaults_json")
            oc.value = params["data"].to_json
            oc.save
            render json: {status: 200, message: "Success"}
        end
   
    end
  end
end