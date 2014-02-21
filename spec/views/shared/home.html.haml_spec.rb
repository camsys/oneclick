require "spec_helper"
require "cs_helpers"
require "support/oneclick_spec_helpers"

describe "shared/home.html.haml" do

    before(:all) do
        factory = FactoryGirl.create(:cms_snippet)
        I18n.locale = :en
    end

  it "accurately pulls from the CMS" do
    assign(:actions, [])
    render
    expect(rendered).to include("FG Snippet Text")
  end
end