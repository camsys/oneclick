class Admin::AdminHomeController < Admin::BaseController
  authorize_resource :class => false

  # before_filter :setup_actions
  def index
    @admin_actions = admin_menu
    render 'home'
  end

  def controller_name
    'admin home'
  end
  
end
