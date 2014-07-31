require 'spec_helper'

describe HomeController do

  describe "GET 'index'" do
    it "should be successful" do
      pending "See https://www.pivotaltracker.com/story/show/68068948"
      get 'index'
      response.should be_success
    end
  end

end
