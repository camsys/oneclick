class Kiosk::InitializeEcolaneLoginsController < TravelerAwareController
  def show
    redirect_to kiosk_user_ecolane_login_path(@traveler)    
  end  
end
