
class ProvidersController < TravelerAwareController

  before_filter :get_traveler

  def index
    @providers = Provider.active
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @providers }
      format.csv do
        filter_params = params.permit(:bIncludeInactive, :search)

        @providers = Provider.get_exported(@providers, filter_params)

        render_csv("providers.csv", @providers, Provider.csv_headers)
      end
    end
  end

  def show
    @provider = Provider.find(params[:id].to_i)
  end
end
