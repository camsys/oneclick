module Export
  class ServicesController < Export::ExportApiController
    def index
      render json: Service.all.map{ |s| ServiceSerializer.new(s).serializable_hash }
    end
  end
end
