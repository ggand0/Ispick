$ ->
  $('#modal-window').modal('show')
  #$("#modal-window").html("<%= escape_javascript(render 'users/new_avatar') %>")