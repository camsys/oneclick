require 'rake'

namespace :oneclick do
  desc "Load database translations from config/locales/moved-to-db/*.yml files (idempotent)"
  task load_locales: :environment do
  	locales_directory = Rails.root.to_s + "/config/locales/"

    Dir.foreach(locales_directory) do |filename|
    	
      unless filename == "." || filename == ".."

	      puts "Loading locale file #{filename}"

	      y = YAML.load_file(locales_directory + filename)

	      failed = success = skipped = 0
	      y.each_with_parents do |parents, v|
	        locale = parents.shift
	        locale = Locale.find_or_create_by(name: locale)
	        if v.is_a? Array
	          translation_key_name = parents.join('.')
	          translation_value = v.join(',')
	          translation_key = TranslationKey.find_or_create_by!(name: translation_key_name)
	          new_translation = Translation.find_or_create_by!(translation_key_id: translation_key.id, locale_id: locale.id) do |new_translation|
	          	new_translation.value = translation_value
	          	new_translation.is_list = true
	          end
	        else
	          translation_key_name = parents.join('.')
	          translation_value = v
	          translation_key = TranslationKey.find_or_create_by!(name: translation_key_name)
	          new_translation = Translation.find_or_create_by!(translation_key_id: translation_key.id, locale_id: locale.id) do |new_translation|
	          	new_translation.value = translation_value
	          end
	        end
	        new_translation.id.nil? ? failed += 1 : success += 1
	      end

	      puts "Read #{success+failed} keys, #{success} successful, #{failed} failed, #{skipped} skipped"

  		end

    end
  end
end