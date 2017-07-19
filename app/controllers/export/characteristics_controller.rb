module Export
  class CharacteristicsController < Export::ExportApiController
    def index
      render json: Characteristic.all.map{ |obj| CharacteristicSerializer.new(obj).serializable_hash }
    end
  end
end