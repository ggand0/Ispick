# Board追加dialogの更新
$ ->
  console.log('modal_board.js has been loaded.')

  $('#new_image_board').on("ajax:success", (e, data, status, xhr) ->
    console.log('ajax of new_board has succeeded.')
    ###$("#modal-board").modal('toggle')
    $('#modal-board').removeData('bs.modal')
    $("#modal-board").modal('show')###

    target = $('.modal-id')
    $.ajax({
      url: '/image_boards/boards',
      type: 'get',
      data: { image: target.html() },
      dataType: 'script',
      success: () ->
        console.log("Successfully called 'image_boards/boards'")
      error: () ->
        console.log("Error during calling 'image_boards/boards'")
    })
  )