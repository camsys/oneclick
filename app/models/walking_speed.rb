class WalkingSpeed < ActiveRecord::Base
	has_many :users

	SLOW = 'slow'
	AVERAGE = 'average'
	FAST = 'fast'

	def label
		case code
		when SLOW
			TranslationEngine.translate_text(code) + ' (<=' + value.to_s + ' mph)'
		when AVERAGE
			TranslationEngine.translate_text(code) + ' (=' + value.to_s + ' mph)'
		when FAST
			TranslationEngine.translate_text(code) + ' (>=' + value.to_s + ' mph)'
		end
	end
end
