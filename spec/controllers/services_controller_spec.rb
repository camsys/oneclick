require 'spec_helper'

describe ServicesController do
  # This should return the minimal set of attributes required to create a valid
  # Service. As you add validations to Service, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { {
      name: 'a service',
      provider: FactoryGirl.create(:provider),
      service_type: FactoryGirl.create(:service_type)
    } }
  
  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # ServicesController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  before (:all) do
    FactoryGirl.create(:admin)
  end

  after (:all) do
    User.delete_all
  end

  before (:each) do
      login_as_using_find_by(email: 'admin@example.com')
  end

  describe "GET index" do
    it "assigns all services as @services" do
      service = Service.create! valid_attributes
      get :index, {}, valid_session
      assigns(:services).should eq [service]
    end
  end

  describe "GET show" do
    it "assigns the internal contact to @contact" do
      service = Service.create! valid_attributes
      get :show, {id: service.to_param}, valid_session
      assigns(:contact).should be_nil
      contact = FactoryGirl.create(:service_contact, service: service)
      contact.add_role :internal_contact, service
      get :show, {id: service.to_param}, valid_session
      assigns(:contact).should eq contact
    end
  end
  
end
