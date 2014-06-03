window.Clip = {}

Clip.addClipEvents = (do_render) ->
  console.log('Adding events...')
  $favored = $('.clip_button')

  $favored.click((e) ->
    id = $(this).parentsUntil('.boxInner').children('.id').html()
    board_name = $(this).text()
    console.log(id)
    console.log(board_name)

    url = '/delivered_images/' + id + '/favor'
    $target = $(this).parentsUntil('.boxInner').children('.dropdown-toggle')
    console.log($target)

    $.ajax({
      url: url,
      type: 'PUT',
      data: { render: do_render, board: board_name }
      success: (result) ->
        # Class変更
        $target.attr('class', "dropdown-toggle btn-info btn btn-info")

        if not do_render
          document.location.reload(true)
    })

    e.preventDefault()
  )

Clip.removeClipEvents = () ->
  $favored = $('.clip_button')
  $favored.off('click')
