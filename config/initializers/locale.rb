require 'i18n/backend/active_record'
I18n.backend = I18n::Backend::Chain.new(I18n::Backend::ActiveRecord.new, I18n.backend)

module I18n
  class MissingTranslationExceptionHandler < ExceptionHandler # affect I18n.t()
    def call(exception, locale, key, options)
      if exception.is_a?(MissingTranslation)
      	if I18n.locale == :tags
          key
        else
          super
        end
      else
        super
      end
    end
  end
end

I18n.exception_handler = I18n::MissingTranslationExceptionHandler.new