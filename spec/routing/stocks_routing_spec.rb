require "spec_helper"

describe StocksController do
  describe "routing" do

    it "routes to #index" do
      get("/stocks").should route_to("stocks#index")
    end
  end
end
