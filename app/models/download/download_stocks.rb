# -*- coding: utf-8 -*-
require 'csv'
require 'open-uri'

# 株価取得
class DownloadStocks
  # 株価情報をダウンロードする
  def download
    #url = "http://k-db.com/site/download.aspx?p=all&download=csv"
    url = "http://k-db.com/?p=all&download=csv"
    open(url, 'r:Shift_JIS', "User-Agent" => "Mozilla/5.0") do |data|
      csv = data.read
      import_csv(csv)
    end

    OfxGen.new.generate_all
    return # no return value
  end

  private

  # 株価 CSV ファイルをパースし、データを保存
  def import_csv(csv)
    STDERR.puts "importing CSV"

    ActiveRecord::Base::transaction() do
      lineno = 0
      date = nil
      CSV.parse(csv) do |cols|
        lineno += 1

        # 1行目
        if (lineno == 1)
          # 日付を取得する
          date = Date.parse(cols[0])
          STDERR.puts "Date = #{date}"
          next
        end

        if (lineno == 2)
          # チェック
          if (cols.length != 10 || cols[0] != "コード" ||
              cols[7] != "終値")
            throw "Invalid CSV file format (2nd line"
          end
          next
        end

        # 通常行
        code = cols[0]
        name = cols[1]
        price = cols[7].to_f
        
        # コードチェック
        if code =~ /(\d\d\d\d)-T/
          code = $1
          #STDERR.puts "code = #{code}"
        else
          next
        end

        # 価格チェック
        next if price == 0

        # 既存エントリを探す
        stock = Stock.where(code: code).first
        if !stock
          stock = Stock.new
          stock.code = code
        end
        stock.name = name
        stock.price = price
        stock.lastdate = date
        stock.save
      end
    end
  end
end
