# -*- coding: utf-8 -*-
require 'csv'
require 'open-uri'

# 株価取得
class DownloadStocks
  # rails4_runner 用
  def execute
    download
  end

  # 株価情報をダウンロードする
  def download
    #旧URL
    #url = "http://k-db.com/site/download.aspx?p=all&download=csv"

    ## Method 1: こちらはフォーマットが異なる
    #url = "http://k-db.com/?p=all&download=csv"

    ## Method 2
    today = Date.today
    url = "http://k-db.com/stocks/#{today.to_s}?download=csv"

    begin
      open(url, 'r:Shift_JIS', "User-Agent" => "Mozilla/5.0") do |data|
        csv = data.read
        import_csv(csv, today)
      end
    rescue => e
      puts "download failed : #{e}"
      exit 1
    end

    OfxGen.new.generate_all

    STDERR.puts "Done!"

    return # no return value
  end

  private

  # 株価 CSV ファイルをパースし、データを保存
  def import_csv(csv, date)
    STDERR.puts "importing CSV"

    ActiveRecord::Base::transaction() do
      lineno = 0
      #date = nil
      CSV.parse(csv) do |cols|
        lineno += 1

        # 1行目
        if (lineno == 1)
          # 日付
          STDERR.puts "Date = #{cols[0]}"
          next
        end

        if (lineno == 2)
          # チェック
          if (cols.length != 10 || cols[0] != "コード" ||
          cols[2] != "銘柄名" ||
              cols[7] != "終値")
            throw "Invalid CSV file format (2nd line)"
          end
          next
        end

        # 通常行
        code = cols[0]
        name = cols[2]
        price = cols[7].to_f

        #STDERR.puts "#{code}, #{name}, #{price}" #debug

        # コードチェック
        if code =~ /(\d\d\d\d)-T/
          code = $1
          #STDERR.puts "code = #{code}"
        else
          next
        end

        # 価格チェック
        next if price == 0

        # debug
        #pp "----", code, name, price, date

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
