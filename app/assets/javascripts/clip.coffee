window.Clip = {}

Clip.addClipEvents = (do_render) ->
  console.log('Adding events...')
  $favored = $('.favored')
  $favored.click((e) ->
    id = $(this).children('.id').html()
    url = '/delivered_images/' + id + '/favor'
    $target = $(this).children('span')
    $.ajax({
      url: url,
      type: 'PUT',
      data: { render: do_render }
      success: (result) ->
        # css変更
        is_favored = (result is 'true')
        color = if is_favored then '#02C293' else '#000'
        text = if is_favored then 'Clipped' else 'Clip'
        $target.css('color', color)
        $target.text(text)

        if not do_render
          document.location.reload(true)
    })
  )