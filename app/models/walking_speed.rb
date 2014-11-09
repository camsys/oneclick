class WalkingSpeed < ActiveRecord::Base
	has_many :users

	SLOW = 'slow'
	AVERAGE = 'average'
	FAST = 'fast'

	def label
		case code
		when SLOW
			I18n.t(code) + ' (<=' + value.to_s + ' mph)'
		when AVERAGE
			I18n.t(code) + ' (=' + value.to_s + ' mph)'
		when FAST
			I18n.t(code) + ' (>=' + value.to_s + ' mph)'
		end
	end
end
