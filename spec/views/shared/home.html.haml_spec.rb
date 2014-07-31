require "spec_helper"
require "cs_helpers"
require "support/oneclick_spec_helpers"

describe "shared/home.html.haml" do

    before(:each) do
        I18n.locale = :en
        assign(:actions, [])
        render
    end

    # This wasn't really testing the view, but missing l10n strings
  # it "respects the locale" do
  #   expect(rendered).to include("locale=en")
  # end
end