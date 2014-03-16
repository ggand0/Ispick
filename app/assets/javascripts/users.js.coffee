# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  addClipEvent = () ->
    $favored = $('.favored')
    console.log($favored)

    console.log($favored.children('.id'))
    $favored.click((e) ->
      console.log('Begin clipping request.')
      #$.getJSON('/model_data/' + $(@).text() + '.json', (data) ->

      #console.log($(this).children('.id').html())
      id = $(this).children('.id').html()
      url = '/delivered_images/' + id + '/favor'
      #$.post('/delivered_images/' + id + '/favor', (data) ->
      $.ajax({
        url: url,
        type: 'PUT',
        success: (result) ->
          console.log('Succeeded to clip!')
      })
    )

  addClipEvent()