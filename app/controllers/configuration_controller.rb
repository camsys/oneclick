class ConfigurationController < ApplicationController

  skip_filter :set_locale, :get_traveler, :setup_actions, :clear_location

  def configuration
    config = {UiMode: ENV['UI_MODE'] || 'desktop'}
    respond_to do |format|
      format.json { render json: config }
    end

  end
end

