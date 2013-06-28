class HomeController < ApplicationController

  def index
    @actions = [
        {label: 'Plan a Trip', target: new_trips_path, icon: 'icon-bus-sign'},
        {label: 'Identify Places', target: '#', icon: 'icon-map-marker'},
        {label: 'Change My Settings', target: '#', icon: 'icon-cog'},
        {label: 'Help & Support', target: '#', icon: 'icon-question-sign'},
    ]
  end

end
