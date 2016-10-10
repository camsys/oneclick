module ItineraryHelper
	include MapHelper

	def logo_path_from_view_helper(item)
		(item.logo_url.nil? ? '' : ActionController::Base.helpers.asset_path(item.logo_url))
	end

	def create_static_map(itinerary)
		legs = itinerary.get_legs
		if itinerary.is_mappable
			markers = create_itinerary_markers(itinerary)
			polylines = create_itinerary_polylines(legs)
		end

		params = {
			'size' => '700x435',
			'maptype' => 'roadmap',
			'client_id' =>  ENV['GOOGLE_GEOCODER_ACCOUNT'],
			'channel' => ENV['GOOGLE_GEOCODER_CHANNEL']
		}

		iconUrls = {
			'blueMiniIcon' => 'https://maps.gstatic.com/intl/en_us/mapfiles/markers2/measle_blue.png',
			'startIcon' => 'http://maps.google.com/mapfiles/dd-start.png',
			'stopIcon' => 'http://maps.google.com/mapfiles/dd-end.png'
		}

		markersByIcon = markers.group_by { |m| m["iconClass"] }

		url = "https://maps.googleapis.com/maps/api/staticmap?" + params.to_query
		markersByIcon.keys.each do |iconClass|
			marker = '&markers=icon:' + iconUrls[iconClass]
			markersByIcon[iconClass].each do |icon|
				marker += '|' + icon["lat"].to_s + "," + icon["lng"].to_s
			end
			url += URI::encode(marker)
		end

		polylines.each do |polyline|
			enc = Polylines::Encoder.encode_points(polyline['geom'])
			url += URI::encode('&path=color:0x0000ff|weight:5|enc:' + enc)
		end

		open(url, 'rb').read
	end


end
