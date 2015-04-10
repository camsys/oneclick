module Api
  module V1
    class AccommodationsController < ApplicationController
      respond_to :json
      require 'json'

      def index
        accommodations = Accommodation.where(active: true)

        accommodations_questions = []
        accommodations.each do |accommodation|
          note = I18n.t(accommodation.note)
          code = accommodation.code
          type = accommodation.datatype
          accommodations_questions.append({text: note, code: code, type: type})
        end

        hash = {accommodations_questions: accommodations_questions}
        respond_with hash
      end

      def list
        index
      end

    end
  end
end