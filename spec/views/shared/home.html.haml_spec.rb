require "spec_helper"
require "cs_helpers"
require "support/oneclick_spec_helpers"

describe "shared/home.html.haml" do

    before(:each) do
        I18n.locale = :en
        assign(:actions, [])
        render
    end

  it "respects the locale" do
    expect(rendered).to include("locale=en")
  end
end