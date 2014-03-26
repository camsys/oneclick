require "spec_helper"
include Devise::TestHelpers

describe ApplicationController do
  #This is required because ApplicationController doesn't have any actions in it, so we monkeypatch them in.
  controller do
    def index
      render nothing: true
    end
  end

  before (:each) do
    @user = FactoryGirl.create(:user)
    sign_in @user
  end
  
  describe "set_locale" do
    it "should use the locale in the URL if set" do
      get :index, :locale => 'en'
      expect(I18n.locale).to eq(:en)
    end

    it "should not change the users preference" do
      @user2 = FactoryGirl.create(:user2)
      @user2.update_attributes(preferred_locale: 'es')
      @user2.reload
      expect(I18n.locale).to eq(:en)
      expect(@user2.preferred_locale).to eq('es')
    end
  end
end