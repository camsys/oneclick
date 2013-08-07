require 'spec_helper'

describe AdminsController do

  describe "GET 'index'" do
    it "returns http success" do
      get 'index'
      response.status.should eq 302
    end
  end

end
