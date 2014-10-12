class @Scroll
  constructor: ->
    console.log('scroll constructor called')
    $el = $('.wrap')
    @listView = new infinity.ListView($el)
    @scrollReady = true

  infiniteScroll: (logging) =>
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

    $(window).scroll =>
      #console.log(@scrollReady)
      return if @scrollReady == false

      url = $('nav.pagination a[rel=next]').attr('href')
      if url and $(window).scrollTop() > $(document).height() - $(window).height() - 50
        $('.pagination').text("Fetching more products...")
        @scrollReady = false
        $.getScript(url)
        $.ajax({
          cache: false,
          url: url,
          type: 'GET',
          dataType: 'html',
          success: (data) =>
            @listView.append($(data).find('.box'))
            console.log(@listView.pages[0].items.length)
            @scrollReady = true
          failure: (data) =>
            console.log('failed')
            @scrollReady = true
        })
    ######

