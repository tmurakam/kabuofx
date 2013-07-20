json.array!(@stocks) do |stock|
  json.extract! stock, :code, :name, :price, :lastdate
  json.url stock_url(stock, format: :json)
end
