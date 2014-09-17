require 'i18n/backend/active_record'
if ENV['DONT_USE_I18N_FALLBACK']
  I18n.backend = I18n::Backend::Chain.new(I18n::Backend::ActiveRecord.new)
else
  I18n.backend = I18n::Backend::Chain.new(I18n::Backend::ActiveRecord.new, I18n.backend)
end

module I18n
  class MissingTranslationExceptionHandler < ExceptionHandler # affect I18n.t()
    def call(exception, locale, key, options)
      if exception.is_a?(MissingTranslation)
      	if I18n.locale == :tags
          '[' + key.to_s + ']'
        else
          super
        end
      else
        super
      end
    end
  end

  class Utility
    def self.load_locale filename
      y = YAML.load_file(filename)
      failed = success = skipped = 0
      y.each_with_parents do |parents, v|
        locale = parents.shift
        if v.is_a? Array
          Translation.create(key: parents.join('.'), locale: locale, value: v.join(','), is_list: true).id.nil? ? failed += 1 : success += 1
        else
          Translation.create(key: parents.join('.'), locale: locale, value: v).id.nil? ? failed += 1 : success += 1
        end
      end
      puts "Read #{success+failed} keys, #{success} successful, #{failed} failed, #{skipped} skipped"
    end
  end

end

I18n.exception_handler = I18n::MissingTranslationExceptionHandler.new