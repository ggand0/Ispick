#= require 'component'
window.onload = () ->
  #alert('first visit or from the back button?')
window.onunload = () ->

ready = ->
  console.log('document.ready called')
  Turbolinks.pagesCached(0)

  ###if $("#refresh").length > 0
    console.log('#refresh exists')
    if ($("#refresh").val() == 'yes')
      console.log('reloading!')
      location.reload(true)
    else
      console.log('first visit')
      $('#refresh').val('yes')###

  # Dropdown: Close the dialog when clicked
  window.component = new Component()
  window.component.initDropdowns()

  # Modal:
  # Display some specific modals without background color
  window.component.initModals()

  # For autocompleting tags
  $("#q_tags_name_cont").autocomplete({
    source: '/tags/autocomplete.json',
  })

$(document).ready(ready)
$(document).on('page:load', ready)