class FareHelper

  def calculate_fare(itinerary)

    #Check to see if a flat rate exists
    itinerary.cost = itinerary.service.fare_structures.where(fare_type: 0).pluck(:base).min

    #Check to see if a complex fare structure exists
    unless itinerary.cost
      itinerary.cost_comments = itinerary.service.fare_structures.where(fare_type: 2).pluck(:desc).first
    end

    itinerary.save
  end

end