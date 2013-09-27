class Admin::Controller < ApplicationController

  # cancan authorization for the controller
  authorize_resource :class => false
  
  def index
    
    @actions = [
        {label: t(:find_traveler), target: error_501_path, icon: ACTION_ICONS[:find_traveler]},
        {label: t(:create_traveler), target: error_501_path, icon: ACTION_ICONS[:create_traveler]},
        {label: t(:agents_agencies), target: error_501_path, icon: ACTION_ICONS[:agents_agencies]},
        {label: t(:reports), target: admin_reports_path, icon: ACTION_ICONS[:reports]},
    ]
    
    render '/admin/index'
  end
  
end
