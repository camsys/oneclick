class HomeController < ApplicationController

  def index
    @actions = [
        {label: t(:plan_a_trip), target: new_trips_path, icon: 'icon-bus-sign'},
        {label: t(:identify_places), target: '#', icon: 'icon-map-marker'},
        {label: t(:change_my_settings), target: '#', icon: 'icon-cog'},
        {label: t(:help_and_support), target: '#', icon: 'icon-question-sign'},
    ]
  end
  
end
