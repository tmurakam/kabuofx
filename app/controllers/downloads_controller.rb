# -*- coding: utf-8 -*-
class DownloadsController < ApplicationController
  # メイン画面
  def index
  end

  # コード編集画面
  def codes
  end

  # OFX ダウンロード
  def ofx
    codes = params[:codes]
    if codes.nil?
      send_file "public/ofx/kabuofx.ofx", :type => "application/x-ofx"
    else
      gen = OfxGen.new
      ofx_string = gen.generate_from_codes(codes.split(/,/))
      send_data ofx_string, :type => 'application/x-ofx'
    end
  end
end
