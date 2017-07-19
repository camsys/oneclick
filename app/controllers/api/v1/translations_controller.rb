module Api
  module V1
    class TranslationsController < Api::V1::ApiController

      def find

        locale = Locale.find_by(name: params[:locale])
        translations = params[:translations]
        translated = {}

        translations.each do |translation|
          trans = Translation.find_by(locale: locale, key: translation)

          #The gsub finds all instances of %{xyz} and replaces then with {{xyz}} The {{xyz}} string is used by Angular for interpolation
          translated[translation] = trans.nil? ? nil : trans.value.gsub(/%\{[a-zA-Z_]+\}/) { |s| '{{' + s[2..-2] + '}}' }
        end

        render status: 200, json: translated
        return

      end


      def all
        dictionaries = {}

        if params[:lang]
          locale = Locale.find_by_name(params[:lang])
          dictionary = {} #Translation.where(locale: locale).each {|t| {t.key => t.value}}

          #The gsub finds all instances of %{xyz} and replaces then with {{xyz}} The {{xyz}} string is used by Angular for interpolation
          Translation.where(locale: locale).each {|translation| dictionary[translation.key] = translation.value.gsub(/%\{[a-zA-Z_]+\}/) { |s| '{{' + s[2..-2] + '}}' } }
          dictionaries = dictionary
        else
          Locale.all.each do |locale|
            dictionary = {} #Translation.where(locale: locale).map {|t| {t.key => t.value}}

            #The gsub finds all instances of %{xyz} and replaces then with {{xyz}} The {{xyz}} string is used by Angular for interpolation
            Translation.where(locale: locale).each {|translation| dictionary[translation.key] = translation.value.gsub(/%\{[a-zA-Z_]+\}/) { |s| '{{' + s[2..-2] + '}}' } }
            dictionaries[locale.name] = dictionary
          end
        end

        render status: 200, json: dictionaries
        return
      end

    end
  end
end