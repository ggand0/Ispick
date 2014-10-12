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
    ###$(".wrap").infinitescroll({
      navSelector: "nav.pagination"               # selector for the paged navigation (it will be hidden)
      nextSelector: "nav.pagination a[rel=next]"  # selector for the NEXT link (to page 2)
      itemSelector: ".box"                        # selector for all items you'll retrieve
    },
    (arrayOfNewElems) ->
      #window.Clip.removeClipEvents(true)
      #window.Clip.initButtons(true)
    )###
    $el = $('.wrap')
    window.listView = new infinity.ListView($el)
    window.scrollReady = true
    $(window).scroll ->
      console.log(window.scrollReady)
      return if window.scrollReady == false

      url = $('nav.pagination a[rel=next]').attr('href')
      if url and $(window).scrollTop() > $(document).height() - $(window).height() - 50
        $('.pagination').text("Fetching more products...")
        window.scrollReady = false
        $.getScript(url)
        $.ajax({
          cache: false,
          url: url,
          type: 'GET',
          dataType: 'html',
          success: (data) ->
            window.listView.append($(data).find('.box'))
            console.log(window.listView.pages[0].items.length)
            window.scrollReady = true
          failure: (data) ->
            console.log('failed')
            window.scrollReady = true
        })


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
          $('.titleD').removeClass('notransition')
      )
    )
    # Initialize all popovers
    $('.popover-board').popover({
      html: true,
      content: '',
      #trigger: 'manual'
      #trigger: 'click'
    }).popover('hide')


  initDropdowns: () ->
    $('.dropdown-user').click (e) ->
      $("body").trigger("click")

  # Initializes the backdrop colors of the modals
  initModals: () ->
    $('.modal-avatar').on('show.bs.modal hide.bs.modal', (e) ->
      $('body').toggleClass('modal-color-none')
    )
    $('#modal-image').on('show.bs.modal hide.bs.modal', (e) ->
      $('body').toggleClass('modal-color-none')
    )

  initBoards = () ->
    #
    $('.user_boards').on("click", (e, data, status, xhr) ->
      $('#modal-board').modal('hide')
    )