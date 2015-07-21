module ItineraryHelper

	def logo_path_from_view_helper(item)
		(item.logo_url.nil? ? '' : ActionController::Base.helpers.asset_path(item.logo_url))
	end

end