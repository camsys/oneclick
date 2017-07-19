module Export
  class EligibilitySerializer < ExportSerializer
    attributes :code,
               :phrases

    def self.collection_serialize(collection)
      ActiveModelSerializers::SerializableResource.new(collection, each_serializer: self)
    end

    def phrases

      words = {}

      I18n.available_locales.each do |locale|
        #It is not a bug that note and question are the same.  In Oneclick Legacy, there is no question
        I18n.locale = locale
        words[locale] = {name: TranslationEngine.translate_text(object.name), note: TranslationEngine.translate_text(object.note), question: TranslationEngine.translate_text(object.note)}
      end

      words
    end

  end
end
