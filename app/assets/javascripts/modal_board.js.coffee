# Board追加dialogの更新
$ ->
  $('.user_boards').on("click", (e, data, status, xhr) ->
    $('#modal-board').modal('hide')
  )
  # Popoverに変更したので今は使用していない
  #console.log('modal_board.js has been loaded.')
  #$('.user_boards').on("click", (e, data, status, xhr) ->
  #  $('#modal-board').modal('hide')
  #)

