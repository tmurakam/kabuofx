$ ->
  # コード編集画面チェック
  return if $("#code_rows").length == 0

  # Model
  Stock = Backbone.Model.extend
    defaults:
      name: '-'
      price: '-'
      date: '-'
      
    validate: (attrs) ->
      if !(/^\d\d\d\d$/.test(attrs.code))
        return "コードは4桁の整数で入力してください"
      if @collection.findWhere({code: attrs.code})
        return "コードが重複しています"
      return

    initialize: ->
      @listenTo this, 'invalid', (model, error) ->
        alert error

  # Collection
  Stocks = Backbone.Collection.extend
    model: Stock

    initialize: ->
      @loading = false
      @listenTo this, "add", @save
      @listenTo this, "remove", @save

    # code でソート
    comparator: 'code'

    # local storage から設定ロード
    load: ->
      @loading = true
      codes = JSON.parse(localStorage.getItem "codes") || []
      _.each codes, (code) ->
        if code
          stock = new Stock
            code: code
            collection: this
          this.add(stock)
      , this
      @loading = false
      @download_stocks()
      return

    # local storage に設定保存
    save: ->
      if !@loading
        codes = @get_codes()
        localStorage.setItem "codes", JSON.stringify codes

    # 証券コード配列を得る
    get_codes: ->    
      codes = []
      _(@models).each (model) ->
        code = model.get 'code'
        codes.push code if code
        return
      codes

    # サーバから証券情報を取得する
    download_stocks: ->
      codes = @get_codes()
      $.ajax
        context: this
        type: "GET"
        url: "/api/stocks/#{codes.join(',')}"
        dataType: "json"
        success: (data, status, xhr) ->
          _.each @models, (model) ->
            d = data[model.get 'code']
            if d
              model.set
                name: d.name
                price: d.price
                date: d.date
          , this
      return
              
  # View
  StockView = Backbone.View.extend
    tagName: 'tr'

    initialize: ->
      @listenTo @model, 'change', @render
      @listenTo @model, 'destroy', @remove

    template: _.template("<td><%= code %></td><td><%= name %></td><td><%= price %></td><td><%= date %></td><td><button class='delete btn btn-danger'>削除</button></td>")

    events:
      'click .delete': 'destroy'

    destroy: ->
      #if (confirm('are you sure?'))
      @collection.remove @model
      @model.destroy()

    remove: ->
      @$el.remove()
      
    render: ->
      html = @template @model.toJSON()
      @$el.html html
      return this
      
  StocksView = Backbone.View.extend
    el: "#code_rows"

    initialize: ->
      @views = []
      @listenTo @collection, 'change', @render

    add_stock: (stock) ->
      stockView = new StockView
        model: stock
        collection: @collection
      @$el.append stockView.render().el
      @views.push stockView
      return

    # メモリリーク対策。view全解放
    dispose: ->
      _.each @views, (view) ->
        view.remove()
      @views = []
      return
      
    render: ->
      @$el.empty()
      @dispose()
      @collection.each (stock) ->
        @add_stock stock
        return
      , this
      return this

  AddStockView = Backbone.View.extend
    el: "#add_code_form"

    events:
      'click #add_code': 'add_code'
      'keypress #code_field': 'keypress'
      
    keypress: (e) ->
      if e.witch == 13 || e.keyCode == 13
        e.preventDefault()
        @add_code(e)
        return false
      else
        return true
        
    add_code: (e) ->
      e.preventDefault()
      
      code = $("#code_field").val()
      $("#code_field").val("")
      
      stock = new Stock {}, {collection: stocks}
      if stock.set 'code', code, {validate: true}
        @collection.add(stock)
        @collection.download_stocks()
        
  DownloadView = Backbone.View.extend
    el: "#download_ofx"
    
    events:
      'click button': 'download_ofx'

    download_ofx: ->
      url = "/downloads/ofx?codes=" + @collection.get_codes().join(",")
      location.href = url
      return

  stocks = new Stocks()
  stocksView = new StocksView({collection: stocks})
  addStockView = new AddStockView({collection: stocks})  
  downloadView = new DownloadView({collection: stocks})
  
  stocks.load()
  