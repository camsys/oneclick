class Admin::UtilController < Admin::BaseController
  
  def geocode
    @results = nil
    @address = params[:geocode][:address] rescue nil
    if @address
      g = OneclickGeocoder.new
      @results = Geocoder.search(params[:geocode][:address], sensor: g.sensor, components: g.components, bounds: g.bounds)
      @results
    end
  end

  def raise
    raise (params[:string] || 'Raising an exception')
  end

end
