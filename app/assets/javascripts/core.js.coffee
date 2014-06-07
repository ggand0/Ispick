$ ->
  #$('#modal-window').modal('show')
  #$("#modal-window").html("<%= escape_javascript(render 'users/new_avatar') %>")

  # Dropdown:
  # click時にdialogを閉じる
  $('.dropdown-user').click (e) ->
    $("body").trigger("click")