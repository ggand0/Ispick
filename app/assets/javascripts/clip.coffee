window.Clip = {}

Clip.addClipEvents = (rendering, logging) ->
  console.log('Adding clip events...') if logging
  $favored = $('.clip_button')

  $favored.click((e) ->
    id = $(this).parentsUntil('.boxInner').children('.id').html()
    board_name = $(this).text()
    url = '/delivered_images/' + id + '/favor'
    $target = $(this).parentsUntil('.boxInner').children('.dropdown-toggle')

    if logging
      console.log(id)
      console.log(board_name)
      console.log($target)

    $.ajax({
      url: url,
      type: 'PUT',
      data: { render: rendering, board: board_name }
      success: (result) ->
        # Class変更
        $target.attr('class', "dropdown-toggle btn-info btn btn-info")
        document.location.reload(true) if not rendering
    })
    e.preventDefault()
  )


Clip.removeClipEvents = () ->
  $favored = $('.clip_button')
  $favored.off('click')
