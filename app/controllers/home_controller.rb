class HomeController < TravelerAwareController

  def index
    if params[:locale]
      # render "shared/home"
      redirect_to new_user_trip_path(@traveler, locale: I18n.locale)
    else
      redirect_to "/#{current_or_guest_user.preferred_locale}/"
    end
  end
end
