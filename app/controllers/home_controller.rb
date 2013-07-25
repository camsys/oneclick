class HomeController < ApplicationController
include CsHelpers

  def index
    @actions = [
        {label: t(:plan_a_trip), target: new_trip_path, icon: ACTION_ICONS[:plan_a_trip]},
        {label: t(:identify_places), target: '#', icon: ACTION_ICONS[:identify_places]},
        {label: t(:change_my_settings), target: '#', icon: ACTION_ICONS[:change_my_settings]},
        {label: t(:help_and_support), target: '#', icon: ACTION_ICONS[:help_and_support]},
    ]
  end

end
