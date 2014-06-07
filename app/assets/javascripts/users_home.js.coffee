# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#= require 'clip'

$ ->
  # クリップ機能
  window.Clip.addClipEvents(true)

  # 無限スクロール
  $('.pagination').hide()
  $(".wrap").infinitescroll({
    navSelector: "nav.pagination"               # selector for the paged navigation (it will be hidden)
    nextSelector: "nav.pagination a[rel=next]"  # selector for the NEXT link (to page 2)
    itemSelector: ".box"                        # selector for all items you'll retrieve
  },
  (arrayOfNewElems) ->
    window.Clip.removeClipEvents(true)
    window.Clip.addClipEvents(true)
  )

  # カレンダー(Datepicker)
  #selector = "[data-behaviour~=datepicker]"
  selector = ".input-group.date"
  $(selector).datepicker().on('changeDate', (ev) ->
    $('.current-date').change()

    date = $(this).datepicker('getDate')
    $(selector).datepicker('hide')

    url = window.location.href
    url = url.split('?')[0]+'?date='+date
    window.location.href = url
  )
  $("body").on("click", ".filter-button", () ->
    $(selector).datepicker('show')
  )

  # Board追加
  $('.new_board').on('click', (e) ->
    input = $(this).parent().children('.form-group').children('.new_board_input')
    e.preventDefault()

    $.ajax({
      url: '/image_boards',
      type: 'post',
      data: { image_board: { name: input.val() }},
      success: () ->
        console.log('Successfully created a new board.')
      error: () ->
    })
  )


