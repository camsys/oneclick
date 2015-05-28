class Admin::PoisController < Admin::BaseController
  authorize_resource :class => false

  def check_loading_status
    status = {
      is_loading: Rails.application.config.poi_is_loading
    }

    status[:loading_summary] = Rails.application.config.poi_last_loading_summary if !status[:is_loading]

    render json: status
  end

  def load_pois 
    info_msgs = []
    error_msgs = []

    if !can?(:load_pois, :pois)
      error_msgs << TranslationEngine.translate_text(:not_authorized)
    else
      poi_file = params[:poi][:file] if params[:poi]
      
      if !poi_file.nil?
        if Rails.application.config.poi_is_loading
          error_msgs << TranslationEngine.translate_text(:pois_being_loading)
        else
          uploader = PoiUploader.new
          begin
            uploader.store!(poi_file)
            OneclickConfiguration.create_or_update(:poi_is_loading, true)
            if Rails.env.development?
              # PoiUploadWorker.perform_async(uploader.path) # need to start sidekiq locally: bundle exec sidekiq
              info_msgs << Poi.load_pois(uploader.path) # if local, then no need to call worker
            else
              PoiUploadWorker.perform_async(uploader.url)
            end
          rescue Exception => ex
            error_msgs << ex.message
          end
        end
      else
        error_msgs << TranslationEngine.translate_text(:select_pois_file_to_upload)
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
