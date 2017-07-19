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

	          #Check if translation exists.  DO NOT overwrite existing translations.
	          existing_translation = Translation.where("translation_key_id = ? AND locale_id = ?", translation_key.id, locale.id)

	          if existing_translation.count == 0

	          	new_translation = Translation.new

	          	new_translation.translation_key_id = translation_key.id
	          	new_translation.locale_id = locale.id

	          	new_translation.value = translation_value
	          	new_translation.is_list = true
	          	new_translation.save!

	          	new_translation.id.nil? ? failed += 1 : success += 1

	          else

	          	skipped += 1

	          end

	        else

	          translation_key_name = parents.join('.')
	          translation_value = v
	          translation_key = TranslationKey.find_or_create_by!(name: translation_key_name)

	          #Check if translation exists.  DO NOT overwrite existing translations.
	          existing_translation = Translation.where("translation_key_id = ? AND locale_id = ?", translation_key.id, locale.id)

	          if existing_translation.count == 0

	          	new_translation = Translation.new

	          	new_translation.translation_key_id = translation_key.id
	          	new_translation.locale_id = locale.id

	          	new_translation.value = translation_value
	          	new_translation.is_list = false
	          	new_translation.save!

	          	new_translation.id.nil? ? failed += 1 : success += 1

	          else

	          	skipped += 1

	          end

	        end

	      end

	      puts "Read #{success+failed} keys, #{success} successful, #{failed} failed, #{skipped} skipped"

  		end

    end
  end

  desc "Load a select group of Spanish translations requiring update."
  task patch_spanish_translations: :environment do

		locales_directory = Rails.root.to_s + "/config/locales/"
		filename = locales_directory + "es_corrected_translations_07_01_2015.yml"

      puts "Loading locale file #{filename}"

      y = YAML.load_file(filename)

      failed = success = skipped = 0
      y.each_with_parents do |parents, v|

      locale = parents.shift
      locale = Locale.find_by(name: locale)

      translation_key_name = parents.join('.')

        translation_value = v
        translation_key = TranslationKey.find_or_create_by!(name: translation_key_name)

        #Check if translation exists.  DO NOT overwrite existing translations.
        existing_translation = Translation.where("translation_key_id = ? AND locale_id = ?", translation_key.id, locale.id)

        if existing_translation.count > 0

        	puts "Warning: duplicate translation detected. es #{translation_key_name}" if existing_translation.count > 1

        	translation_to_update = existing_translation.first

        	if translation_to_update.value.to_s[0..3].downcase == '[es]'
        		translation_to_update.value = translation_value 
        		translation_to_update.save!
        		puts "Success patching translation.  Translation Key: #{translation_key_name}"
        		success += 1
        	else
        		puts "Warning patching translation.  Value doesn't start with [es].  Rather: #{translation_to_update.value.to_s[0..3]}"
        		skipped += 1
        	end

        else
        	puts "Warning patching translation - not found: es. #{translation_key_name}"
        	skipped += 1
        end

      end

      puts "Read #{success+failed} keys, #{success} successful, #{failed} failed, #{skipped} skipped"

		end

end