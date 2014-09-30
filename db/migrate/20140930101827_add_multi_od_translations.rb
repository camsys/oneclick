class AddMultiOdTranslations < ActiveRecord::Migration
  def change
  	%w(multi_od_trip routes grid).each do |key|
  	  Translation.where(:key => key.to_s).destroy_all
    end

  	%w(en es ht).each do |l|
  	  locale = l.to_s
  	  if locale == 'en'
	  	locale_start = ''
	  	locale_end = ''
	  else
	  	locale_start = '[' + locale + ']'
	  	locale_end = '[/' + locale + ']'
	  end
	  Translation.create!(key: 'multi_od_trip', value: locale_start + "Multiple Origin-Destination Trip" + locale_end, locale: locale)
	  Translation.create!(key: 'routes', value: locale_start + "Routes" + locale_end, locale: locale)
	  Translation.create!(key: 'grid', value: locale_start + "Grid" + locale_end, locale: locale)
	end
  end
end
