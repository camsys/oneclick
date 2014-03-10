class Admin::ServicesController < Admin::BaseController
  def index
    @services = if params.include?(:provider_org_id)
      @services = ProviderOrg.find(params[:provider_org_id]).services
    else
      @services = Service.all(order: :name)
    end    
  end
end

