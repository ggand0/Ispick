# Board追加dialogの更新
$ ->
  console.log('modal_board.js has been loaded.')

  # Board追加時に描画し直す
  $('#new_image_board').on("ajax:success", (e, data, status, xhr) ->
    console.log('ajax of new_board has succeeded.')
    #console.log($(this).parent())

    $('#modal-board').modal('hide')
    target = $('.id')
    target_html = $('.html-id')
    console.log('target_html:')
    console.log(target_html.html())
    $.ajax({
      url: '/image_boards/boards',
      type: 'get',
      data: { image: target.html(), id: target_html.html() },
      dataType: 'script',
      #dataType: 'html',
      success: (response) ->
        console.log("    Successfully called 'image_boards/boards'")
      error: () ->
        console.log("    Error during calling 'image_boards/boards'")
    })
  )


  # お気に入り画像を既存Boardに追加した時にmodalを閉じる
  ###$('.users_board').on("ajax:success", (e, data, status, xhr) ->
    console.log('ajax of favor has succeeded.')
    #$('#modal-board').modal('toggle')
    $('#modal-board').modal('hide')
  )###
  $('.user_boards').on("click", (e, data, status, xhr) ->
    $('#modal-board').modal('hide')
  )

