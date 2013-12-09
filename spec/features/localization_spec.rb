require 'spec_helper'

describe HomeController do

  it "should have language-selection links" do
    puts "before visit"
    visit "/"
    puts "before test 1"
    page.should_not have_link("English", href: "/en")
    puts "before test 2"
    page.should have_text("English")
    puts "before test 3"
    page.should have_link(I18n.t(:spanish), href: "/es")
    puts "after test 3"
  end

  it "should switch to spanish when selection link is clicked" do
    visit "/"
    click_link I18n.t(:spanish)
    I18n.locale.should be :es
    # next check isn't really helpful, because locale selection is hidden in t()
    page.should have_text(I18n.t(:plan_a_trip))
  end

  it "should stick to selected language as I navigate" do
    pending "todo"
    visit "/"
    click_link I18n.t(:spanish)
    I18n.locale.should be :es
    click_link I18n.t(:log_in)
    I18n.locale.should be :es
    page.should have_text(I18n.t('simple_form.labels.defaults.email'))
  end

  it "should switch to another locale correctly when in the non-default locale" do
    visit "/"
    click_link I18n.t(:spanish)
    I18n.locale.should be :es
    click_link 'English'
    I18n.locale.should be :en
  end
end
