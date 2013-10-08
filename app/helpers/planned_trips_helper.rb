module PlannedTripsHelper
  
  def get_alt_button_text(itinerary, button_action)
    "#{button_action.capitalize} #{itinerary.mode.name.downcase} option."
  end
  
end