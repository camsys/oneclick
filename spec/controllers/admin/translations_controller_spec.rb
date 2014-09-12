require 'spec_helper'

describe Admin::TranslationsController do

  before(:each) do
    login_as(:admin)
  end

  describe "GET 'index'" do
    it "should provide a list of translations" do
      get :index
      response.should be_success
      # TODO Brittle test; dependent on db seeding
      assigns(:translations_proxies).count.should eql(914)
      assigns(:translations_proxies).first.should be_a(TranslationProxy)
    end
  end

end
