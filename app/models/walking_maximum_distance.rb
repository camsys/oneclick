class WalkingMaximumDistance < ActiveRecord::Base
	has_many :users

	def label
		value.to_s + ' ' + I18n.t(:miles)
	end
end
