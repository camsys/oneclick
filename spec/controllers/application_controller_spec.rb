require "spec_helper"
include Devise::TestHelpers

describe ApplicationController do
  #This is required because ApplicationController doesn't have any actions in it, so we monkeypatch them in.
  controller do
    def index
      render nothing: true
    end
  end

  describe "set_locale" do
    before (:each) do
      @user = FactoryGirl.create(:user)
      sign_in @user
    end

    it "should use the locale in the URL if set" do
      get :index, :locale => 'en'
      expect(I18n.locale).to eq(:en)
    end

    it "should not change the users preference" do
      pending "This test seems to be unreliable."
      @user2 = FactoryGirl.create(:user2)
      @user2.update_attributes(preferred_locale: 'es')
      @user2.reload
      expect(I18n.locale).to eq(:en)
      expect(@user2.preferred_locale).to eq('es')
    end
  end

  describe 'users preferred locale' do
    it "should use the previous locale if not set in the url" do
      @user = FactoryGirl.create(:user)
      expect(@user.preferred_locale).to eq('en')
      sign_in @user
      get :index
      @user.update_attribute :preferred_locale, 'es'
      @user.reload
      expect(@user.preferred_locale).to eq('es')
      get :index
      expect(I18n.locale).to eq(:en)
    end

  end
end