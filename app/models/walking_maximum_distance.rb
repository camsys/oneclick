class WalkingMaximumDistance < ActiveRecord::Base
	has_many :users

	def label
		value.to_s + ' ' + TranslationEngine.translate_text(:miles)
	end
end
