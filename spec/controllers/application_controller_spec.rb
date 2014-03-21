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
        get :index, :locale => :en
        I18n.locale.should be(:en)

        get :index, :locale => :es
        I18n.locale.should be(:es)
      end

      it "should use the default locale if not set in the URL" do
        get :index
        I18n.locale.should be(I18n.default_locale)
      end

      it "should set the preference for a user based on the URL" do
        # @user.preferred_locale = :en #This is the default- language = :en
        puts "COMPARE FROM"
        get :index, :locale => :es
        puts "COMPARE TO"
        @user.reload
        expect(@user.preferred_locale).to eq("es")
      end
  end
end