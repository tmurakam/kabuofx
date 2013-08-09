# -*- coding: utf-8 -*-
class StocksController < ApplicationController
  # GET /stocks
  # GET /stocks.json
  def index
    @stocks = Stock.all
  end

  # 証券名取得
  def name
    @stock = Stock.where(:code => params[:code]).first
    json = {}
    if @stock
      json = {:code => @stock.code, :name => @stock.name}
    end
    render :json => json
  end
end
