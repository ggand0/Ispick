# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#= require 'clip'

$ ->
  addClipEvent = () ->
    $favored = $('.favored')
    $favored.click((e) ->
      id = $(this).children('.id').html()
      url = '/delivered_images/' + id + '/favor'
      $target = $(this).children('span')
      $.ajax({
        url: url,
        type: 'PUT',
        success: (result) ->
          # css変更
          is_favored = (result is 'true')
          color = if is_favored then '#02C293' else '#000'
          text = if is_favored then 'Unclip' else 'Clip'
          $target.css('color', color)
          $target.text(text)
      })
    )

  #addClipEvent()
  #console.log(window.Clip)
  window.Clip.addClipEvents()