class ConfigurationController < ApplicationController

  def configuration
    config = {UiMode: ENV['UI_MODE'] || 'desktop'}
    puts config.ai
    respond_to do |format|
      format.json { render json: config }
    end

  end
end

