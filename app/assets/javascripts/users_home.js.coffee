# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#= require 'clip'
#= require 'component'

$ ->
  # Add clipping related events
  window.Clip.addClipEvents(true)
  # 'Clip'ボタンを押下した時にボタンを表示したままにする
  $(document).on('click', '.popover-board', () ->
    $(this).parents('.boxInner').addClass('hovered')
  )


  # Initialize infinite scroll
  window.Component.infiniteScroll(true)


  # Display the calender (Datepicker)
  window.Component.enableCalender()


  # Popovers: close popover on click wherever except popover windows
  window.Component.enablePopovers()
