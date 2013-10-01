class Admin::UtilController < Admin::Controller
  
  def geocode
    @results = nil
    @address = params[:geocode][:address] rescue nil
    if @address
      g = OneclickGeocoder.new
      @results = Geocoder.search(params[:geocode][:address], sensor: g.sensor, components: g.components, bounds: g.bounds)
      Rails.logger.info "Results: #{@results.ai}"
      Rails.logger.info "Results: #{@results}"
      Rails.logger.info "Results: #{@results.size}"
      Rails.logger.info "Results: #{@results[0].public_methods}"
      # @results = @results[0].data.ai(plain: true)
      @results
    end
  end

end
