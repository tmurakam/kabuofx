# -*- coding: utf-8 -*-
class StocksController < ApplicationController
  # GET /stocks
  # GET /stocks.json
  def index
    @stocks = Stock.all
  end

  # 証券名取得
  def names
    codes = params[:codes].split(/,/)
    json = {}

    codes.each do |code|
      @stock = Stock.where(:code => code).first
      if @stock
        json[@stock.code] = {
          :name => @stock.name,
          :price => @stock.price,
          :date => @stock.lastdate
        }
      end
    end
    render :json => json
  end
end
