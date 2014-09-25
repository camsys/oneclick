class Admin::OneclickConfigurationsController < Admin::BaseController

  authorize_resource
  def index
    @configs = OneclickConfiguration.all
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @configs }
    end

  end
end
