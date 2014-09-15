require 'spec_helper'

describe Admin::TranslationsController do

  before(:each) do
    login_as(:admin)
  end

  describe "GET 'index'" do
    it "should provide a list of translations" do
      get :index
      response.should be_success
      assigns(:translations_proxies).first.should be_a(TranslationProxy)
    end
  end

end
