# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#= require 'component'
#= require 'scroll'

history.navigationMode = 'compatible'


$(document).on 'ready page:load', ->
  console.log('loaded'+window.loaded)
  $(window).on('popState', (event)->
    console.log('POPSTATE')
    window.loaded = false
  )
  $(window).on('pushState', (event)->
    console.log('PUSHSTATE')
    window.loaded = false
  )
  $(window).on('hashchange',()->
    console.log('HASHCHANGE')
    window.loaded = false
  )
  $('body').on('hashchange',()->
    console.log('HASHCHANGE')
    window.loaded = false
    ''
  )
  console.log($('.wrapper').length)
  console.log($('.block').length)
  return if $('.wrapper').length==0

  if window.loaded
    $('.wrapper').unbind()
    $(document).add('*').off()
    #window.$el = $('.wrapper')
    #window.listView = new infinity.ListView(window.$el)
    #window.scrollReady = true
    #window.blocks=[]
    #$('.block').hide()
    #window.scroll = new Scroll()
    #window.scroll.infiniteScroll(true)
    #return

  window.loaded=true



  window.component = new Component()

  # Initialize buttons related to clipping
  window.component.initButtons()



  # Initialize infinite scroll
  #component.infiniteScroll(true)
  window.scroll = new Scroll()
  window.scroll.infiniteScroll(true)

  # Display the calender (Datepicker)
  window.component.initCalender()


  # Popovers: close popover on click wherever except popover windows
  window.component.initPopovers()

#$(document).ready(ready)
#$(document).on('page:load', ready)
