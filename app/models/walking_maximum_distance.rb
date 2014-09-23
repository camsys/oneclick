class WalkingMaximumDistance < ActiveRecord::Base
  	include TranslationTagHelper
	has_many :users

	def label
		value.to_s + ' ' + translate_w_tag_as_default(:miles)
	end
end
