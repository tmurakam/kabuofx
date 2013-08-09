$ ->
  # コード編集画面チェック
  return if $("#code_rows").length == 0

  # model
  codes = []
  stocks = {}    
    
  # コード追加
  add_code = (code) ->
    # 重複チェック
    for c in codes
      if c == code
        return false
    codes.push(code)
    codes.sort()
    return true

  # コード削除
  remove_code = (code) ->
    for i in [0..codes.length-1]
      if codes[i] == code
        codes.splice(i, 1)
        return true
    return false

  # コードをロード
  load_codes = ->
    codes = JSON.parse(localStorage.getItem("codes")) || []
    return
    
  # コードを保存
  save_codes = ->
    localStorage.setItem("codes", JSON.stringify(codes))
    return
    
  # 銘柄情報
  get_stocks = ->
    $.ajax
      type: "GET"
      url: "/stocks/names/#{codes.join(',')}"
      dataType: "json"
      success: (data, status, xhr) ->
        stocks = data
        render()
    return
              
  # View
  render = ->
    tbody = $("#code_rows")
    tbody.empty()
    for code in codes
      stock = stocks[code]
      
      tr = $("<tr></tr>")
      tbody.append(tr)
      
      $("<td></td>").text(code).appendTo(tr)

      td = $("<td></td>").appendTo(tr)
      if stock
        td.text(stock.name)

      td = $("<td></td>").appendTo(tr)
      if stock
        td.text(stock.price)

      td = $("<td></td>").appendTo(tr)
      if stock
        td.text(stock.date)
      
      del = $("<button class='btn btn-danger'>削除</button>")
      # code の値をイベントハンドラ内で使用するため、クロージャにする
      do (code) ->
        del.on "click", ->
            on_remove_code(code)
          return
        return
      $("<td></td>").append(del).appendTo(tr)
    return
    
  # コード追加
  on_add_code = ->
    code = $("#code_field").val()
    $("#code_field").val("")
    if /^\d\d\d\d$/.test(code)
      if add_code(code)
        save_codes()
        render()
        get_stocks()
    else
      alert("コードは4桁の整数で入力してください")
    return
    
  # コード削除
  on_remove_code = (code) ->
    if remove_code(code)
      save_codes()
      render()
    return
    
  # OFX ダウンロード
  download_ofx = ->
    url = "/downloads/ofx?codes=" + codes.join(",")
    location.href = url
    return
    
  # イベントハンドラ設定
  $("#add_code").on "click", on_add_code

  $("#download_ofx").on "click", download_ofx
  
  # Enter キー処理
  $("#add_code_form").keypress (ev) ->
    if (ev.witch == 13 || ev.keyCode == 13)
      on_add_code()
      return false
    else
      return true

  # 初期化
  load_codes()
  render()
  get_stocks()
