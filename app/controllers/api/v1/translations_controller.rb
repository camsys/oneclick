module Api
  module V1
    class TranslationsController < Api::V1::ApiController

      def find
        #params = {locale: "en", translations: ["splash", "medical"]}

        locale = Locale.find_by(name: params[:locale])
        translations = params[:translations]
        translated = {}

        translations.each do |translation|
          trans = Translation.find_by(locale: locale, key: translation)
          translated[translation] = trans.nil? ? nil : trans.value
        end

        render status: 200, json: translated
        return

      end


      def all
        dictionaries = {}

        if params[:lang]
          locale = Locale.find_by_name(params[:locale])
          dictionary = {} #Translation.where(locale: locale).each {|t| {t.key => t.value}}
          Translation.where(locale: locale).each {|translation| dictionary[translation.key] = translation.value }
          dictionaries = dictionary
        else
          Locale.all.each do |locale|
            dictionary = {} #Translation.where(locale: locale).map {|t| {t.key => t.value}}
            Translation.where(locale: locale).each {|translation| dictionary[translation.key] = translation.value }
            dictionaries[locale.name] = dictionary
          end
        end

        render status: 200, json: dictionaries
        return
      end

    end
  end
end