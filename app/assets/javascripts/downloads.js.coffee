$ ->
  insert_row = (code) ->
    alert(code)
    
  $('#add_code').click ->
    code = $('#code_field').val()
    $('#code_field').val('')
    if /^\d\d\d\d$/.test(code)
      insert_row(code)
    else
      alert("コードは4桁の整数で入力してください")
    
    
    
