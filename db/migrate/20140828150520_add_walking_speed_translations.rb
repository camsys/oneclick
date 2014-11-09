class AddWalkingSpeedTranslations < ActiveRecord::Migration
  def change
  	slow = WalkingSpeed::SLOW
  	average = WalkingSpeed::AVERAGE
  	fast = WalkingSpeed::FAST
  	%w(en es ht).each do |locale|
  	  if locale == 'en'
	  	locale_start = ''
	  	locale_end = ''
	  else
	  	locale_start = '[' + locale + ']'
	  	locale_end = '[/' + locale + ']'
	  end
	  Translation.create!(key: slow, value: locale_start + "Slow" + locale_end, locale: locale)
	  Translation.create!(key: average, value: locale_start + "Average" + locale_end, locale: locale)
	  Translation.create!(key: fast, value: locale_start + "Fast" + locale_end, locale: locale)
	end
  end
end
