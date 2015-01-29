class Admin::PoisController < Admin::BaseController
  authorize_resource :class => false

  def load_pois 
    info_msgs = []
    error_msgs = []

    if !can?(:load_pois, :pois)
      error_msgs << t(:not_authorized)
    else
      poi_file = params[:poi][:file] if params[:poi]
      
      if !poi_file.nil?
        if File.extname(poi_file.original_filename) == '.csv'
          filename = poi_file.tempfile.path
          info_msgs << Poi.load_pois(filename)
        else
          error_msgs << t(:pois_file_not_csv)
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
