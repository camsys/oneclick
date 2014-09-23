class WalkingSpeed < ActiveRecord::Base
  	include TranslationTagHelper
	has_many :users

	SLOW = 'slow'
	AVERAGE = 'average'
	FAST = 'fast'

	def label
		case code
		when SLOW
			translate_w_tag_as_default(code) + ' (<=' + value.to_s + ' mph)'
		when AVERAGE
			translate_w_tag_as_default(code) + ' (=' + value.to_s + ' mph)'
		when FAST
			translate_w_tag_as_default(code) + ' (>=' + value.to_s + ' mph)'
		end
	end
end
