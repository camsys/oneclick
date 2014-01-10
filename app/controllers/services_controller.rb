class ServicesController < ApplicationController

  include ApplicationHelper

  def show
    @service = Service.find(params[:id])
    @eh = EligibilityHelpers.new
    respond_to do |format|
      format.html
      format.json { render json: @service }
    end

  end
end

