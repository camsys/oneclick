class Admin::UtilController < Admin::BaseController
  skip_authorization_check
  include TripsSupport

  def geocode
    @results = nil
    @address = params[:geocode][:address] rescue nil
    @map_center = params[:geocode][:map_center] rescue nil
    if @address
      g = OneclickGeocoder.new
      @results = Geocoder.search(params[:geocode][:address], sensor: g.sensor, components: g.components, bounds: g.bounds)

      @autocomplete_results = google_api.get('autocomplete/json') do |req|
        req.params['input']    = @address
        req.params['sensor']   = false
        req.params['key']      = Oneclick::Application.config.google_places_api_key
        # req.params['key']      = 'AIzaSyBHlpj9FucwX45l2qUZ3441bkqvcxR8QDM'
        req.params['location'] = @map_center
        req.params['radius']   = 20_000
      end

      @autocomplete_details = @autocomplete_results.body['predictions'].collect do |p|
        get_places_autocomplete_details(p['reference']).body
      end
    end
  end

  def raise
    raise (params[:string] || 'Raising an exception')
  end

end
