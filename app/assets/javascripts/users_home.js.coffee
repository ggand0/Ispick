# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#= require 'component'
#= require 'scroll'

$(document).on 'ready page:load', ->
  logging = false
  imgLoad = imagesLoaded($('.wrapper'))
  imgLoad.on( 'progress', ( instance, image ) ->
    result = image.isLoaded ? 'loaded' : 'broken'
    console.log( 'image is ' + result + ' for ' + image.img.src ) if logging
  )
  if logging
    console.log('loaded'+window.loaded)
    console.log($('.wrapper').length)
    console.log($('.block').length)
  return if $('.wrapper').length==0


  window.component = new Component()

  # Initialize buttons related to clipping
  window.component.initButtons()


  # Initialize infinite scroll
  window.scroll = new Scroll(logging)
  window.scroll.infiniteScroll()

  # Display the calender (Datepicker)
  window.component.initCalender()


  # Popovers: close popover on click wherever except popover windows
  window.component.initPopovers()

