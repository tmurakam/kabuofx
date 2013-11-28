# -*- coding: utf-8 -*-
require 'spec_helper'

describe StocksController do

  # This should return the minimal set of attributes required to create a valid
  # Stock. As you add validations to Stock, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { { "code" => "1234" } }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # StocksController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET index" do
    it "assigns all stocks as @stocks" do
      stock = Stock.create! valid_attributes
      get :index, {}, valid_session
      assigns(:stocks).should eq([stock])
    end
  end

  describe "GET api_index" do
    before do
      FactoryGirl.create :stock
    end

    it "パラメータがない場合に @json に空データ値を設定すること" do
      get :api_index, { :codes => "" }, valid_session
      assigns(:json).should eq({})
    end

    it "該当コードがない場合に @json に空データ値を設定すること" do
      get :api_index, { :codes => "2222,3333,4444,5555" }, valid_session
      assigns(:json).should eq({})
    end

    it "該当コードがある場合に、@json にデータを設定すること" do
      get :api_index, { :codes => "1111" }, valid_session
      assigns(:json).should eq({ "1111" => {:name => "テスト", :price => 1234.0, :date => Date::new(2013, 7, 20) }})
    end
  end
end
