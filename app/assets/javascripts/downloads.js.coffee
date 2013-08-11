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
      @listenTo(this, 'invalid', (model, error) ->
        alert(error)
      )

  # Collection
  Stocks = Backbone.Collection.extend
    model: Stock

    initialize: ->
      @listenTo(this, "remove", @save)

    # code でソート
    comparator: 'code'
                                                      
    load: ->
      codes = JSON.parse(localStorage.getItem("codes")) || []
      _.each(codes, (code, index, list) ->
        if code
          stock = new Stock({code: code, collection: this})
          this.add(stock)
      this)
      
    save: ->
      codes = @get_codes()
      localStorage.setItem("codes", JSON.stringify(codes))

    get_codes: ->    
      codes = []
      _.each(@models, (model, index, list) ->
        code = model.get('code')
        if code
          codes.push(model.get('code'))
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
          _.each(@models, (model) ->
            d = data[model.get('code')]
            if d
              model.set('name', d.name)
              model.set('price', d.price)
              model.set('date', d.date)
              model.trigger('change')
          this)
      return
              
  # View
  StockView = Backbone.View.extend
    tagName: 'tr'

    initialize: ->
      @listenTo(@model, 'change', @render)
      @listenTo(@model, 'destroy', @remove)

    template: _.template("<td><%= code %></td><td><%= name %></td><td><%= price %></td><td><%= date %></td><td><button class='delete btn btn-danger'>削除</button></td>")

    events:
      'click .delete': 'destroy'

    destroy: ->
      #if (confirm('are you sure?'))
      @collection.remove(@model)
      @model.destroy()

    remove: ->
      @$el.remove()
      
    render: ->
      html = @template(@model.toJSON())
      @$el.html(html)      
      return this
      
  StocksView = Backbone.View.extend
    el: "#code_rows"

    initialize: ->
      @listenTo(@collection, 'change', @render)
            
    render: ->
      @$el.empty()
      @collection.each((stock) ->
        stockView = new StockView({model: stock, collection: @collection})
        @$el.append(stockView.render().el)
        return
      this)
      return this

  AddStockView = Backbone.View.extend
    el: "#add_code_form"

    events:
      'click #add_code': 'add_code'
      'keypress #code_field': 'keypress'
      
    keypress: (e) ->
      if (e.witch == 13 || e.keyCode == 13)
        e.preventDefault()
        @add_code(e)
        return false
      else
        return true
        
    add_code: (e) ->
      e.preventDefault()
      
      code = $("#code_field").val()
      $("#code_field").val("")
      
      stock = new Stock({}, {collection: stocks})
      if stock.set('code', code, {validate: true})
        @collection.add(stock)
        @collection.save()
        @collection.get_stocks()

  # OFX ダウンロード
  download_ofx = ->
    url = "/downloads/ofx?codes=" + stocks.get_codes().join(",")
    location.href = url
    return
    
  $("#download_ofx").on "click", download_ofx

  stocks = new Stocks()
  stocksView = new StocksView({collection: stocks})
  addStockView = new AddStockView({collection: stocks})  

  stocks.load()
  stocks.get_stocks()
  