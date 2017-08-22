module Export
  class OneclickConfigurationsController < Export::ExportApiController

    def index
      config_hash = {}

      OneclickConfiguration.all.each do |oc|
        config_hash[oc.code] = oc.value
      end

      render json: config_hash
    end

  end
end
