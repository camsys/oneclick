require 'spec_helper'

describe HomeController do
  include CsHelpers
  include Warden::Test::Helpers
  Warden.test_mode!
  
  unless CsHelpers::ui_mode_kiosk?
    it "should have language-selection links" do
      visit "/"
      page.should_not have_link("English", href: "/en")
      page.should have_text("English")
      page.should have_link(TranslationEngine.translate_text(:spanish))
    end

    it "should switch to spanish when selection link is clicked" do
      visit "/"
      click_link TranslationEngine.translate_text(:spanish)
      I18n.locale.should be :es
      # next check isn't really helpful, because locale selection is hidden in t()
    end

    it "should stick to selected language as I navigate" do
      visit "/"
      click_link TranslationEngine.translate_text(:spanish)
      I18n.locale.should be :es
      click_link TranslationEngine.translate_text(:log_in)
      I18n.locale.should be :es
      page.should have_text('Correo electrónico')
      # page.should have_text(TranslationEngine.translate_text('simple_form.labels.defaults.email'))
    end

    it "should switch to another locale correctly when in the non-default locale" do
      visit "/"
      click_link TranslationEngine.translate_text(:spanish)
      I18n.locale.should be :es
      click_link 'English'
      I18n.locale.should be :en
    end

    # it "should use the users default at root" do
    #   user = FactoryGirl.create(:spanish_user)
    #   login_as(user, :scope => :user)
    #   visit '/'
    #   expect(I18n.locale).to eq(:es)
    #   logout(:user)
    #   Warden.test_reset! 
    # end

    # it "should use the users default on login and not change the user's default" do
    #   user = FactoryGirl.create(:spanish_user)
    #   login_as(user, :scope => :user)
    #   expect(I18n.locale).to eq(:es)
    #   logout(:user)
    #   Warden.test_reset! 
    # end
  end
end
