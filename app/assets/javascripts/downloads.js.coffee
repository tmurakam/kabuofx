$ ->
  # コード編集画面チェック
  return if $("#code_rows").length == 0

  # Model
  Stock = Backbone.Model.extend
    validate: (attrs) ->
      if @collection.collection.findWhere({code: attrs.code})
        return "コード重複"
      return

  # Collection
  Stocks = Backbone.Collection.extend
    model: Stock
      
    load: ->
      codes = JSON.parse(localStorage.getItem("codes")) || []
      _.each(codes, (element, index, list) ->
        this.add(new Stock(element))
      this)
      
    save: ->
      codes = @get_codes()
      localStorage.setItem("codes", JSON.stringify(codes))

    get_codes: ->    
      codes = []
      _.each(@models, (element, index, list) ->
        codes.push(element.code)
      )
      return codes
      
    get_stocks: ->
      codes = @get_codes()
      $.ajax
        context: this
        type: "GET"
        url: "/api/stocks/#{codes.join(',')}"
        dataType: "json"
        success: (data, status, xhr) ->
          _.each(@models, (model, index, list) ->
            d = data[model.code]
            if d
              model.price = d.price
              model.name = d.name
              model.date = d.date
          this)
          # render?
      return
              
  # View
  StockView = Backbone.View.extend
    tagName: 'tr'

    initialize: ->
      @listenTo(@model, 'change', @change)
      @listenTo(@model, 'remove', @remove)

    template: _.template("<td><%= code %></td><td><%= name %></td><td><%= price %></td><td><%= date %></td><button class='delete btn btn-danger'>削除</button>")

    events:
      'click .delete': 'destroy'

    destroy: ->
      if (confirm('are you sure?'))
        @model.destroy
        
    render: ->
      html = @template(@model.toJSON())
      @$el.html(html)      
      this
      
  StocksView = Backbone.View.extend
    el: "#code_rows"
    
    render: ->
      @collection.each((stock) ->
        stockView = new StockView({model: stock})
        @$el.append(stockView.render().el)
      this)
      return this

  AddStockView = Backbone.View.extend
    el: "#add_code_form"

    events:
      'click #add_code': 'add_code'
      'keypress #add_code_form': 'keypress'
      
    keypress: (e) ->
      if (e.witch == 13 || e.keyCode == 13)
        add_code(e)
        return false
      else
        return true
        
    add_code: (e) ->
      e.preventDefault()
      
      code = $("#code_field").val()
      $("#code_field").val("")
      
      if /^\d\d\d\d$/.test(code)
        if add_code(code)
          stock = new Stock({code: code})
          @collection.add(stock)
          @collection.save()
          @collection.get_stocks()
      else
        alert("コードは4桁の整数で入力してください")

  # OFX ダウンロード
  download_ofx = ->
    url = "/downloads/ofx?codes=" + stocks.get_codes().join(",")
    location.href = url
    return
    
  $("#download_ofx").on "click", download_ofx

  stocks = new Stocks()
  stocksView = new StocksView({collection: tasks})
  addStockView = new AddStockView({collection: tasks})  

  stocks.load()
  stocks.get_stocks()
  

  # 初期化
  load_codes()
  render()
  get_stocks()
