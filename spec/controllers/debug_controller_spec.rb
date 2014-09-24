require 'spec_helper'

describe DebugController do

  describe "GET 'index'" do
    it "returns http success" do
      get 'debug/index'
      response.should be_success
    end
  end

end
