class HomeController < TravelerAwareController

  def index
    redirect_to new_user_trip_path(@traveler)
  end
end
