require "spec_helper"

describe DownloadsController do
  describe "routing" do

    it "routes to #index" do
      get("/downloads").should route_to("downloads#index")
    end

    it "routes to #ofx" do
      get("/downloads/ofx").should route_to("downloads#ofx")
    end

    it "'root' routes to #index" do
      get("/").should route_to("downloads#index")
    end
  end
end
