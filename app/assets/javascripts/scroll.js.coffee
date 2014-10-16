Array.min = (array) ->
  return Math.min.apply(Math, array)
Array.max = (array) ->
  return Math.max.apply(Math, array)



class @Scroll
  constructor: ->
    #console.log('scroll constructor called')
    @colCount=0
    @colWidth=0
    @margin=20
    @windowWidth=0
    window.blocks=[]
    @counter = 0

  masonry: () ->
    $container = $('.wrapper')
    $container.masonry({
       itemSelector: '.block',
       gutter: 20,
       gutterWidth: 20,
       animate: true,
       columnWidth: 300;
    })
    $('.block').css('margin-bottom', 20+'px')
    $('.wrapper').hide()
    # call the layout method after all elements have been loaded
    $container.imagesLoaded( ->
      $('.wrapper').show()
      $container.masonry()

    )
    $container.masonry()


  setupBlocks: ()=>
    @windowWidth = $(window).width()
    @colWidth = $('.block').outerWidth()
    @colCount = Math.floor(@windowWidth/(@colWidth+@margin))
    for i in [0..@colCount-1]
      defHeight = $('.wrapper').offset().top
      #console.log(defHeight)
      window.blocks.push(defHeight)
    console.log(window.blocks)

  initPositionBlocks: ()=>
    self = @
    $('.block').each(()->
      min = Array.min(window.blocks)
      index = $.inArray(min, window.blocks)
      leftPos = self.margin+(index*(self.colWidth+self.margin))
      $(this).css({
        'left':leftPos+'px',
        'top':min+'px'
      })
      $(this).show()
      window.blocks[index] = min+$(this).outerHeight()+self.margin
    )
    console.log(window.blocks)

  positionBlocks: (newElemsCount) =>
    self = @
    $container = $('.block')
    $container.slice(Math.max($container.length - newElemsCount, 1)).each (()->
      min = Array.min(window.blocks)
      index = $.inArray(min, window.blocks)
      leftPos = self.margin+(index*(self.colWidth+self.margin))
      $(this).show()
      $(this).css({
        'left':leftPos+'px',
        'top':min+'px'
      })
      window.blocks[index] = min+$(this).outerHeight()+self.margin
    )
    console.log(window.blocks)

  updateSpinner: ()=>
    max = Array.max(window.blocks)
    $('#loader').css({
      'top':max+'px'
      'left':(@colCount/2)*@colWidth+'px'
    })
    ###setInterval(()=>
      frames= 12
      frameWidth = 128
      offset= @counter * -frameWidth
      #console.log(offset + "px 0px")
      $("#loader").css('backgroundPosition', offset + "px 0px")
      @counter += 1
      @counter =0 if (@counter>=frames)
    , 100)###


  infiniteScroll: (logging) =>
    console.log('infiniteScroll called') if logging
    $('.pagination').hide()
    @.fastInfiniteScroll()

    ###if document.URL.indexOf('home') > -1
      console.log('home')
    else# normal slow scroll in other pages
      console.log('other than home')###


  fastInfiniteScroll: ()=>
    console.log('fast scrolling with infinity.js')
    $('.block').hide()
    @.setupBlocks()
    @.updateSpinner()

    $('.wrapper').imagesLoaded( =>
      $('#loader').hide()
      console.log('image loaded')
      @.initPositionBlocks()
    )

    window.$el = $('.wrapper')
    window.listView = new infinity.ListView(window.$el)
    window.scrollReady = true

    $(window).scroll =>
      #console.log(window.scrollReady)
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
          success: (data) =>
            $newElements = $(data).find('.block')
            $newElements.hide()
            window.listView.append($newElements)
            count = window.listView.pages[0].items.length
            console.log(count+': '+window.listView.pages[0].items[count-1])

            window.scrollReady = true
            @.updateSpinner()
            $('#loader').show()
            $('.wrapper').imagesLoaded( =>
              $('#loader').hide()

              @.positionBlocks($newElements.length)
            )
          failure: (data) ->
            console.log('failed')
            window.scrollReady = true
        })

  normalInfiniteScroll: ()=>
    @.masonry()
    console.log('normal scrolling with infinite-scroll lib')
    $(".wrapper").infinitescroll({
      navSelector: "nav.pagination"               # selector for the paged navigation (it will be hidden)
      nextSelector: "nav.pagination a[rel=next]"  # selector for the NEXT link (to page 2)
      itemSelector: ".block"                        # selector for all items you'll retrieve
      loading: {
        img: '/assets/round_loader_mini.gif'
      }
    },
    (newElements) ->
      $newElems = $( newElements )
      console.log($newElems.length)
      $container = $(".wrapper")
      $newElems.hide()
      $container.masonry( 'appended', $newElems )
      $container.imagesLoaded( ->
        $container.masonry()
        $newElems.show()
      )
    )


  ###infiniteScroll: (logging) =>
    console.log('infiniteScroll called') if logging
    $('.pagination').hide()
    $(window).scroll =>
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
    ###

