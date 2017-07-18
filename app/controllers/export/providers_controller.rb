module Export
  class ProvidersController < Export::ExportApiController
    def index
      render json: Provider.all.map{ |p| ProviderSerializer.new(p).serializable_hash }
    end
  end
end
