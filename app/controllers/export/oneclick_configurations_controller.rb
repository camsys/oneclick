module Export
  class OneclickConfigurationsController < Export::ExportApiController

    def index
      config_hash = {}

      OneclickConfiguration.all.each do |oc|
        config_hash[oc.code] = oc.value
      end

      if ENV['UBER_SERVER_TOKEN']
        config['ENV_UBER_SERVER_TOKEN'] = ENV['UBER_SERVER_TOKEN']
      end

      if ENV['TAXI_FARE_FINDER_API_KEY']
        config['ENV_TAXI_FARE_FINDER_API_KEY'] = ENV['TAXI_FARE_FINDER_API_KEY']
      end


      render json: config_hash
    end

  end
end
