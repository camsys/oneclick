class ServicesController < ApplicationController

  include ApplicationHelper

  def show
    @services = Service.all(:order => "name")

    if params['service']
      params[:id] = params['service']['id']
    end

    @service = Service.find(params[:id])
    polylines = {}
    ['origin', 'destination', 'residence'].each do |rule|
      coverages = @service.service_coverage_maps.where(rule: rule).type_polygon.first
      polylines[rule] = []
      if coverages
        geometry = Boundary.find(3).geom
        polylines[rule] << {
          "id" => 0,
          "geom" => geometry,
          "options" =>  {"color" => 'red', "width" => "5"}
        }
      end
    end
    @polylines = {}
    @polylines['origin'] = polylines['origin'].to_json || nil
    @polylines['destination'] = polylines['destination'].to_json || nil
    @polylines['residence'] = polylines['residence'].to_json || nil

    @eh = EligibilityHelpers.new
    respond_to do |format|
      format.html
      format.json { render json: @service }
    end

  end
end
