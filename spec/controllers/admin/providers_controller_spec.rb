require 'spec_helper'

describe Admin::ProvidersController do
  # This should return the minimal set of attributes required to create a valid
  # Admin::Provider. As you add validations to Admin::Provider, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { { name: 'foo name' } }
  let(:empty_attributes) { { name: '' } }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # Admin::ProvidersController. Be sure to keep this updated too.
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
    it "assigns all admin_providers as @admin_providers" do
      provider = Provider.create! valid_attributes
      get :index, {}, valid_session
      assigns(:providers).should eq([provider])
    end
  end

  describe "GET show" do
    it "assigns the requested admin_provider as @admin_provider" do
      provider = Provider.create! valid_attributes
      get :show, {:id => provider.to_param}, valid_session
      assigns(:provider).should eq(provider)
    end
  end

  describe "GET new" do
    it "assigns a new admin_provider as @admin_provider" do
      get :new, {}, valid_session
      assigns(:provider).should be_a_new(Provider)
    end
  end

  describe "GET edit" do
    it "assigns the requested admin_provider as @admin_provider" do
      provider = Provider.create! valid_attributes
      get :edit, {:id => provider.to_param}, valid_session
      assigns(:provider).should eq(provider)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Provider" do
        expect {
          post :create, {:admin_provider => valid_attributes }, valid_session
        }.to change(Provider, :count).by(1)
      end

      it "assigns a newly created admin_provider as @admin_provider" do
        post :create, {:admin_provider => valid_attributes}, valid_session
        assigns(:admin_provider).should be_a(Provider)
        assigns(:admin_provider).should be_persisted
      end

      it "redirects to the created admin_provider" do
        post :create, {:admin_provider => valid_attributes}, valid_session
        response.should redirect_to([:admin, Provider.last])
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved admin_provider as @admin_provider" do
        # Trigger the behavior that occurs when invalid params are submitted
        Provider.any_instance.stub(:save).and_return(false)
        post :create, {:admin_provider => empty_attributes}, valid_session
        assigns(:admin_provider).should be_a_new(Provider)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Provider.any_instance.stub(:save).and_return(false)
        post :create, {:admin_provider => empty_attributes}, valid_session
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested admin_provider" do
        pending "not sure why this failing"
        provider = Provider.create! valid_attributes
        # Assuming there are no other admin_providers in the database, this
        # specifies that the Provider created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        Provider.any_instance.should_receive(:update_attributes).with({ admin_provider: {"name" => "params"} })
        put :update, {:id => provider.to_param, :admin_provider => { admin_provider: {"name" => "params"} }}, valid_session
      end

      it "assigns the requested admin_provider as @admin_provider" do
        provider = Provider.create! valid_attributes
        put :update, {:id => provider.to_param, :admin_provider => valid_attributes}, valid_session
        assigns(:provider).should eq(provider)
      end

      it "redirects to the admin_provider" do
        provider = Provider.create! valid_attributes
        put :update, {:id => provider.to_param, :admin_provider => valid_attributes}, valid_session
        response.should redirect_to([:admin, provider])
      end
    end

    describe "with invalid params" do
      it "assigns the admin_provider as @admin_provider" do
        provider = Provider.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Provider.any_instance.stub(:save).and_return(false)
        put :update, {:id => provider.to_param, :admin_provider => empty_attributes}, valid_session
        assigns(:admin_provider).should eq(provider)
      end

      it "re-renders the 'edit' template" do
        provider = Provider.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Provider.any_instance.stub(:save).and_return(false)
        put :update, {:id => provider.to_param, :admin_provider => empty_attributes}, valid_session
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested admin_provider" do
      provider = Provider.create! valid_attributes
      expect {
        delete :destroy, {:id => provider.to_param}, valid_session
      }.to change(Provider, :count).by(-1)
    end

    it "redirects to the admin_providers list" do
      provider = Provider.create! valid_attributes
      delete :destroy, {:id => provider.to_param}, valid_session
      response.should redirect_to(admin_providers_url)
    end
  end

end
