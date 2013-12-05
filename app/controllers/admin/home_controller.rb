class Admin::HomeController < Admin::BaseController

  # before_filter :setup_actions
  def index
    @actions = [
        {label: t(:find_traveler), target: error_501_path, icon: ACTION_ICONS[:find_traveler]},
        {label: t(:create_traveler), target: error_501_path, icon: ACTION_ICONS[:create_traveler]},
        {label: t(:trips), target: admin_trips_path, icon: ACTION_ICONS[:trips]},
        {label: t(:agents_agencies), target: error_501_path, icon: ACTION_ICONS[:agents_agencies]},
        {label: t(:reports), target: admin_reports_path, icon: ACTION_ICONS[:reports]},
    ]
    render '/shared/home'
  end

  def controller_css_class
    'home'
  end
  
end
