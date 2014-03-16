# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  addClipEvent = () ->
    $favored = $('.favored')
    $favored.click((e) ->
      console.log('Begin clipping request.')
      console.log($(this).children('span'))

      id = $(this).children('.id').html()
      url = '/delivered_images/' + id + '/favor'
      $target = $(this).children('span')
      $.ajax({
        url: url,
        type: 'PUT',
        success: (result) ->
          console.log('Succeeded to clip!')
          console.log(typeof(result))
          console.log(result)

          # css変更
          is_favored = (result is 'true')
          console.log('favored:'+is_favored)
          #color = is_favored ? '#02C293' : '#000'
          #text = is_favored ? 'Unclip' : 'Clip'
          color = if is_favored then '#02C293' else '#000'
          text = if is_favored then 'Unclip' else 'Clip'

          $target.css('color', color)
          $target.text(text)
      })
    )

  addClipEvent()