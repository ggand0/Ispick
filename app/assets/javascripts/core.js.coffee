$ ->
  #$('#modal-window').modal('show')
  #$("#modal-window").html("<%= escape_javascript(render 'users/new_avatar') %>")

  $('.dropdown-user').click (e) ->
    console.log('dropdown clicked.')
    #console.log($(this))
    #$(this).dropdown('toggle')
    $("body").trigger("click")

  $('#modal-window').on('hidden.bs.modal', () ->
    console.log('modal closed.')
    #$('.dropdown-user').dropdown('toggle')
  )
  #$('.change-avatar-button').click (e) ->
  #  $('#modal-window').modal('hide');

  # Avatar画像が変更された後にリロードする
  $('.change-avatar-form')
    .on("ajax:success", (data, status, xhr) ->
      console.log('Successfully changed the avatar.')
      #$('.current-avatar').hide()
      #$('.current-avatar').show()
      $$('div.current-avatar')[0].reload()
      #$('#modal-window').modal('hide')
    )
    .on("ajax:error", (xhr, status, error) ->
    )