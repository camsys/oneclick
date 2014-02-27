class Admin::HomeController < Admin::BaseController

  # before_filter :setup_actions
  def index
    @actions = admin_menu
    render '/shared/home'
  end

  def controller_css_class
    'home'
  end
  
end
