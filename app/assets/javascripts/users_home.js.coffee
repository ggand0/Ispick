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

  window.onhashchange = () ->
    alert('changed')
  $(window).on('popstate', () ->
    alert('popState')
  )



  window.component = new Component()

  # Initialize buttons related to clipping
  window.component.initButtons()


  # Initialize infinite scroll or pagination
  #window.scroll = new Scroll(logging)
  #Home.set(logging)
  #home = Home.get()
  #home = new Home(logging)
  ###$("body").off()
  $(window).off()
  imgLoad = imagesLoaded( $('.wrapper') )
  imgLoad.off('always')###
  sc = new Scroll(logging)
  x = 0



  # Initiate infinite scrolling or just aligning images for pagination
  if scroll
    #window.scroll.infiniteScroll()
    sc.infiniteScroll()
  else
    #window.scroll.alignImages()
    sc.alignImages()

  $("#button").click(->
    x = 1

  )
  $("#check-x").click(->
    console.log(x)
    console.log(sc.blocks)
  )


  window.component.initCollapsables()

  # Display the calender (Datepicker)
  window.component.initCalender()


  # Popovers: close popover on click wherever except popover windows
  window.component.initPopovers()

