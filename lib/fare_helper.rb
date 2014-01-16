class FareHelper

  def calculate_fare(itinerary)

    #Check to see if a flat rate exists
    my_fare = itinerary.service.fare_structures.where(fare_type: 0).order(:base).first

    if my_fare
      itinerary.cost = my_fare.base
      itinerary.cost_comments= my_fare.desc
    else
      itinerary.cost_comments = itinerary.service.fare_structures.where(fare_type: 2).pluck(:desc).first
    end

    itinerary.save
  end

end