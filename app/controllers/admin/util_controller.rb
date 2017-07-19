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
        req.params['key']      = Oneclick::Application.config.google_places_api_key
        req.params['location'] = @map_center
        req.params['radius']   = Oneclick::Application.config.config.google_radius_meters
        req.params['components'] = Oneclick::Application.config.geocoder_components
      end

      @autocomplete_details = @autocomplete_results.body['predictions'].collect do |p|
        get_places_autocomplete_details(p['place_id'], p['reference']).body
      end
    end
  end

  #def raise
  #  raise (params[:string] || 'Raising an exception')
  #end


  def settings
    authorize! :settings, :util
  end

  def upload_application_logo
    info_msgs = []
    error_msgs = []
    if !can?(:upload_application_logo, :util)
      error_msgs << TranslationEngine.translate_text(:not_authorized)
    else
      file = params[:logo][:file] if params[:logo]
      
      if !file.nil?
        uploader = ApplicationLogoUploader.new
        begin
          uploader.store!(file)
        rescue Exception => ex
          error_msgs << ex.message
        end

        if OneclickConfiguration.create_or_update(:ui_logo, uploader.url)
          info_msgs << TranslationEngine.translate_text(:logo) + " " + TranslationEngine.translate_text(:was_successfully_updated)
        else
          error_msgs << TranslationEngine.translate_text(:failed_to_update_application_logo)
        end
      else
        error_msgs << TranslationEngine.translate_text(:select_image_to_upload)
      end
    end

    if error_msgs.size > 0
      flash[:error] = error_msgs.join(' ')
    elsif info_msgs.size > 0
      flash[:notice] = info_msgs.join(' ')
    end

    respond_to do |format|
      format.js
      format.html {redirect_to admin_settings_path}
    end
  end

  def upload_favicon
    info_msgs = []
    error_msgs = []
    if params[:favicon]
      favicon = :favicon
    elsif params[:mobile_favicon]
      favicon = :mobile_favicon
    elsif params[:tablet_favicon]
      favicon = :tablet_favicon
    end

    if !can?(:upload_favicon, :util)
      error_msgs << TranslationEngine.translate_text(:not_authorized)
    else
      if params[:favicon]
        file = params[:favicon][:file]
      elsif params[:mobile_favicon]
        file = params[:mobile_favicon][:file]
      elsif params[:tablet_favicon]
        file = params[:tablet_favicon][:file]
      end
      
      if !file.nil?
        uploader = FaviconUploader.new
        begin
          uploader.store!(file)
        rescue Exception => ex
          error_msgs << ex.message
        end

        if OneclickConfiguration.create_or_update(favicon, uploader.url)
          info_msgs << TranslationEngine.translate_text(:favicon) + " " + TranslationEngine.translate_text(:was_successfully_updated)
        else
          error_msgs << TranslationEngine.translate_text(:failed_to_update_favicon)
        end
      else
        error_msgs << TranslationEngine.translate_text(:select_favicon_to_upload)
      end
    end

    if error_msgs.size > 0
      flash[:error] = error_msgs.join(' ')
    elsif info_msgs.size > 0
      flash[:notice] = info_msgs.join(' ')
    end

    respond_to do |format|
      format.js
      format.html {redirect_to admin_settings_path}
    end
  end

end
