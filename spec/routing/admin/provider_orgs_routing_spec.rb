require "spec_helper"

describe Admin::ProviderOrgsController do
  describe "routing" do

    it "routes to #index" do
      get("/admin/provider_orgs").should route_to("admin/provider_orgs#index")
    end

    it "routes to #new" do
      get("/admin/provider_orgs/new").should route_to("admin/provider_orgs#new")
    end

    it "routes to #show" do
      get("/admin/provider_orgs/1").should route_to("admin/provider_orgs#show", :id => "1")
    end

    it "routes to #edit" do
      get("/admin/provider_orgs/1/edit").should route_to("admin/provider_orgs#edit", :id => "1")
    end

    it "routes to #create" do
      post("/admin/provider_orgs").should route_to("admin/provider_orgs#create")
    end

    it "routes to #update" do
      put("/admin/provider_orgs/1").should route_to("admin/provider_orgs#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/admin/provider_orgs/1").should route_to("admin/provider_orgs#destroy", :id => "1")
    end

  end
end
