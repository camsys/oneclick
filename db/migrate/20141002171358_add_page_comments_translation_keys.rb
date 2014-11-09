class AddPageCommentsTranslationKeys < ActiveRecord::Migration
  def change
  	locales = %w(en es ht)
  	pages = %w{trip options grid review plan}

  	page_comment_keys = []
  	pages.each do |p|
  	  page_comment_keys << p.to_s + '_header_comment'
  	  page_comment_keys << p.to_s + '_footer_comment'
  	end

  	locales.each do |l|
  	  page_comment_keys.each do |key|
  	  	if Translation.where(key: key, locale: l.to_s).first.nil?
  	  	  Translation.create!(key: key, locale: l.to_s, value: '')
  	  	end
  	  end
	end
  end
end
