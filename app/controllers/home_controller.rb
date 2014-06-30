class HomeController < TravelerAwareController

  def index
    redirect_to new_user_trip_path(@traveler, locale: I18n.locale)
  end
end
