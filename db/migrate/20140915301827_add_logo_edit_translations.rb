class AddLogoEditTranslations < ActiveRecord::Migration
  def change
  	I18n.available_locales.each do |l|
  	  locale = l.to_s
  	  if locale == 'en'
	  	locale_start = ''
	  	locale_end = ''
	  else
	  	locale_start = '[' + locale + ']'
	  	locale_end = '[/' + locale + ']'
	  end
	  Translation.create!(key: 'remove_logo', value: locale_start + "Remove Logo" + locale_end, locale: locale)
	  Translation.create!(key: 'upload_logo', value: locale_start + "Upload Logo" + locale_end, locale: locale)
	end
  end
end
