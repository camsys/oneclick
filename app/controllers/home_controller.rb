class HomeController < TravelerAwareController

  def index
    if params[:locale]
      render "shared/home"
    else
      redirect_to "/#{current_or_guest_user.preferred_locale}/"
    end
  end
end
