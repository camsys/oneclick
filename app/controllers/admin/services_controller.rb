class Admin::ServicesController < Admin::BaseController
  before_filter :load_services
  load_and_authorize_resource

  def index
  end

  protected

  def load_services
    @services = if params.include?(:provider_org_id)
      @services = ProviderOrg.find(params[:provider_org_id]).services
    else
      @services = Service.all(order: :name)
    end    
  end

end

