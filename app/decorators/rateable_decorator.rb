class RateableDecorator < Draper::Decorator
  delegate_all

  def new_rateable_rating_path
    case object
    when Trip
      return h.new_trip_rating_path(object)
    when Agency
      return h.new_agency_rating_path(object)
    when Service
      return h.new_service_rating_path(object)
    #can't rate providers
    end
  end

  # Do not confuse with RatingDecorator#rating_in_stars which performs equivalent action for Rating model (which is not a Rateable model)
  def rating_in_stars(size=1)
    h.to_stars(object.get_avg_rating, size)
  end
end