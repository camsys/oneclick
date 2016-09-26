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

    if !can?(:update_callnride_boundary, :oneclick_configuration)
      error_msgs << TranslationEngine.translate_text(:not_authorized)
    else
      boundary_file = params[:oneclick_configuration][:file] if params[:oneclick_configuration]
      if !boundary_file.nil?
        gs = GeographyServices.new
        info_msgs << gs.store_callnride_boundary(boundary_file.tempfile.path) # if local, then no need to call worker
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
