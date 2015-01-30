class Admin::PoisController < Admin::BaseController
  authorize_resource :class => false

  def check_loading_status
    render json: {is_loading: Rails.application.config.poi_is_loading}
  end

  def load_pois 
    info_msgs = []
    error_msgs = []

    if !can?(:load_pois, :pois)
      error_msgs << t(:not_authorized)
    else
      poi_file = params[:poi][:file] if params[:poi]
      
      if !poi_file.nil?
        if Rails.application.config.poi_is_loading
          error_msgs << t(:pois_being_loading)
        else
          uploader = PoiUploader.new

          uploader.store!(poi_file)
          OneclickConfiguration.create_or_update(:poi_is_loading, true)
          if Rails.env.development?
            Poi.load_pois(uploader.path)
          else
            PoiUploadWorker.perform_async(uploader.url)
          end

        end
      else
        error_msgs << t(:select_pois_file_to_upload)
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
