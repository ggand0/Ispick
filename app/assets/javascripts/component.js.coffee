class @Component
  constructor: () ->

  # 'Clip'ボタンを押下した時にボタンを表示したままにする
  initButtons: () ->
    $(document).on('click', '.popover-board', () ->
      $(this).parents('.boxInner').addClass('hovered')
    )

  infiniteScroll: (logging) ->
    console.log('infiniteScroll called') if logging
    $('.pagination').hide()
    $(".wrap").infinitescroll({
      navSelector: "nav.pagination"               # selector for the paged navigation (it will be hidden)
      nextSelector: "nav.pagination a[rel=next]"  # selector for the NEXT link (to page 2)
      itemSelector: ".box"                        # selector for all items you'll retrieve
    },
    (arrayOfNewElems) ->
      #window.Clip.removeClipEvents(true)
      #window.Clip.initButtons(true)
    )

  initCalender: () ->
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

  initPopovers: () ->
    $('body').on('click', (e) ->
      $('[data-toggle="popover"]').each(() ->
        # the 'is' for buttons that trigger popups
        # the 'has' for icons within a button that triggers a popup
        if (!$(this).is(e.target) && ($(this).has(e.target).length is 0) && $('.popover').has(e.target).length is 0)
          $(this).popover('hide')
          # Clip buttonもついでに消す
          $('.boxInner').removeClass('hovered')
      )
    )

  initDropdowns: () ->
    $('.dropdown-user').click (e) ->
      $("body").trigger("click")

  # Initializes the backdrop colors of the modals
  initModals: () ->
    $('.modal-avatar').on('show.bs.modal hide.bs.modal', (e) ->
      $('body').toggleClass('modal-color-none')
    )
    $('#modal-board').on('show.bs.modal hide.bs.modal', (e) ->
      $('body').toggleClass('modal-color-none')
    )

  initBoards = () ->
    #
    $('.user_boards').on("click", (e, data, status, xhr) ->
      $('#modal-board').modal('hide')
    )