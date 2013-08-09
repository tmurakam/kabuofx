$ ->
  # model
  codes = []

  # コード追加
  add_code = (code) ->
    # 重複チェック
    for c in codes
      if c == code
        return false
    codes.push(code)
    return true

  # コード削除
  remove_code = (code) ->
    for i in [0..codes.length-1]
      if codes[i] == code
        codes.splice(i, 1)
        return true
    return false

  load_codes = ->
    codes = JSON.parse(localStorage.getItem("codes")) || []
    
  save_codes = ->
    localStorage.setItem("codes", JSON.stringify(codes))
    
  # View
  render = ->
    tbody = $("#rows")
    tbody.empty()
    for code in codes
      tr = $("<tr></tr>")
      tbody.append(tr)
      tr.append($("<td></td>").text(code))
      tr.append($("<td></td>"))
      del = $("<button class='btn btn-danger'>削除</button>")
      del.on "click", ->
        on_remove_code(code)
      tr.append($("<td></td>").append(del))
    return
    
  # コード追加
  on_add_code = ->
    code = $("#code_field").val()
    $("#code_field").val("")
    if /^\d\d\d\d$/.test(code)
      if add_code(code)
        save_codes()
        render()
    else
      alert("コードは4桁の整数で入力してください")

  # コード削除
  on_remove_code = (code) ->
    if remove_code(code)
      save_codes()
      render()
    
  # コード追加イベントハンドラ
  $("#add_code").on "click", on_add_code

  $("#add_code_form").keypress (ev) ->
    if (ev.witch == 13 || ev.keyCode == 13)
      on_add_code()
      return false
    else
      return true

  # initialize
  load_codes()
  render()
    
    
