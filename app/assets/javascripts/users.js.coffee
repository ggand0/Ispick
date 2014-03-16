# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  addClipEvent = () ->
    $favored = $('.favored')
    $favored.click((e) ->
      console.log('Begin clipping request.')

      id = $(this).children('.id').html()
      url = '/delivered_images/' + id + '/favor'
      $.ajax({
        url: url,
        type: 'PUT',
        success: (result) ->
          console.log('Succeeded to clip!')
          # css変更

      })
    )

  addClipEvent()