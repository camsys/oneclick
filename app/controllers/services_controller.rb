class ServicesController < ApplicationController

  include ApplicationHelper

  def show
    @services = Service.all(:order => "name")

    if params['service']
      params[:id] = params['service']['id']
    end

    @service = Service.find(params[:id])
    @eh = EligibilityHelpers.new
    respond_to do |format|
      format.html
      format.json { render json: @service }
    end

  end
end

