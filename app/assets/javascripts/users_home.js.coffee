# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#= require 'component'
#= require 'scroll'
#= require 'home'


$(document).on 'ready page:load', ->
  logging = false
  scroll = $('.temp_information').data('scroll')

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



  # Initialize buttons related to clipping
  component = new Component()
  component.initButtons()

  sc = new Scroll(logging)

  # Initiate infinite scrolling or just aligning images for pagination
  if scroll
    sc.infiniteScroll()
  else
    sc.alignImages()

  component.initCollapsables(sc)

  # Display the calender (Datepicker)
  component.initCalender()


  # Popovers: close popover on click wherever except popover windows
  component.initPopovers()

