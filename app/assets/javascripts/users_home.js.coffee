# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
# require 'clip'
#= require 'component'

ready = ->
  component = new Component()

  # Initialize buttons related to clipping
  component.initButtons()


  # Initialize infinite scroll
  component.infiniteScroll(true)


  # Display the calender (Datepicker)
  component.initCalender()


  # Popovers: close popover on click wherever except popover windows
  component.initPopovers()

$(document).ready(ready)
$(document).on('page:load', ready)
