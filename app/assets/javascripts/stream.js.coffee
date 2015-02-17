# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'ready page:load', ->
  console.log('Starting streaming')

  limit = 10000
  source = new EventSource("/debug/stream_csv?limit=" + limit)
  count = 0
  source.addEventListener('update', (e) ->
    # update a div, reload a section of the page
    $('.csv').after(e.data + '<br />')

    count += 1
    if count >= limit
      source.close()
      console.log('streaming completed!!')
  )

