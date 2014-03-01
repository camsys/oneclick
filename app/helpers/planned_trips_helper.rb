module PlannedTripsHelper
  
  def get_alt_button_text(itinerary, button_action)
    # TODO This may need fixing mode.name/code
    "#{button_action.capitalize} #{itinerary.mode.name.downcase} option."
  end
  
end