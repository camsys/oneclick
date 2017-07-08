module Export
  class CharacteristicsController < Export::ExportApiController
    def index
      chars = []
      Characteristic.all.each do |acc|
        chars << CharacteristicSerializer.new(acc).serializable_hash
      end
      render json: chars
    end
  end
end