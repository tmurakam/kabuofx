$ ->
  # model
  codes = []

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
        remove_code(code)
      tr.append(del)
    return
    
  # コード追加
  add_code = ->
    code = $("#code_field").val()
    $("#code_field").val("")
    if /^\d\d\d\d$/.test(code)
      codes.push(code)
      save_codes()
      render()
    else
      alert("コードは4桁の整数で入力してください")

  # コード削除
  remove_code = (code) ->
    for i in [0..codes.length-1]
      if codes[i] == code
        codes.splice(i, 1)
        break
    save_codes()
    render()
    
  # コード追加イベントハンドラ
  $("#add_code").on "click", add_code
  $("#add_code").keypress (ev) ->
    alert(ev)

  # initialize
  load_codes()
  render()
    
    
