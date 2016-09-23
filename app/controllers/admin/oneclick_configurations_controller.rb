class Admin::OneclickConfigurationsController < Admin::BaseController

  authorize_resource
  def index
    @configs = OneclickConfiguration.all
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @configs }
    end

  end

  def set_callnride_boundary

    info_msgs = []
    error_msgs = []

    if false #!can?(:load_pois, :pois)
      error_msgs << TranslationEngine.translate_text(:not_authorized)
    else
      boundary_file = params[:oneclick_configuration][:file] if params[:oneclick_configuration]

      if !boundary_file.nil?

        uploader = CallnrideBoundaryUploader.new
        begin
          uploader.store!(boundary_file)
          # PoiUploadWorker.perform_async(uploader.path) # need to start sidekiq locally: bundle exec sidekiq
          gs = GeographyServices.new
          info_msgs << gs.store_callnride_boundary(uploader.path) # if local, then no need to call worker

        rescue Exception => ex
          error_msgs << ex.message
        end

      else
        error_msgs << "Upload a zip file containing a shape file."
      end
    end

    if error_msgs.size > 0
      flash[:error] = error_msgs.join(' ')
    elsif info_msgs.size > 0
      flash[:success] = info_msgs.join(' ')
    end


    respond_to do |format|
      format.js
      format.html {redirect_to admin_settings_path}
    end
  end
end
