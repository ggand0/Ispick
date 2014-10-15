# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#= require 'component'
#= require 'scroll'

history.navigationMode = 'compatible'
$(document).on 'ready page:load', ->
  component = new Component()

  # Initialize buttons related to clipping
  component.initButtons()



  # Initialize infinite scroll
  component.infiniteScroll(true)
  #scroll = new Scroll()
  #scroll.infiniteScroll(true)

  # Display the calender (Datepicker)
  component.initCalender()


  # Popovers: close popover on click wherever except popover windows
  component.initPopovers()

#$(document).ready(ready)
#$(document).on('page:load', ready)
