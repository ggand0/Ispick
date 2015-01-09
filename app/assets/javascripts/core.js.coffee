#= require 'component'

ready = ->
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