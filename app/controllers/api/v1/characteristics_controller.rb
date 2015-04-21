module Api
  module V1
    class CharacteristicsController < Api::V1::ApiController

      def index
        characteristics = Characteristic.where(active: true)

        characteristics_questions = []
        characteristics.each do |characteristic|
          note = I18n.t(characteristic.note)
          code = characteristic.code
          type = characteristic.datatype
          characteristics_questions.append({text: note, code: code, type: type})
        end

        hash = {characteristics_questions: characteristics_questions}
        respond_with hash
      end

      def list
        index
      end

    end
  end
end