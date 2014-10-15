Array.min = (array) ->
  return Math.min.apply(Math, array)
Array.max = (array) ->
  return Math.max.apply(Math, array)

class @Scroll
  constructor: ->
    console.log('scroll constructor called')
    @colCount=0
    @colWidth=0
    @margin=20
    @windowWidth=0
    @blocks=[]

  setupBlocks: ()=>
    @windowWidth = $(window).width()
    @colWidth = $('.block').outerWidth()
    @colCount = Math.floor(@windowWidth/(@colWidth+@margin))
    for i in [0..@colCount-1]
      defHeight = $('.wrapper').offset().top
      console.log(defHeight)
      @blocks.push(defHeight)
    console.log(@blocks)

  initPositionBlocks: ()=>
    self = @
    $('.block').each(()->
      min = Array.min(self.blocks)
      index = $.inArray(min, self.blocks)
      leftPos = self.margin+(index*(self.colWidth+self.margin))
      $(this).css({
        'left':leftPos+'px',
        'top':min+'px'
      })
      $(this).show()
      self.blocks[index] = min+$(this).outerHeight()+self.margin
    )
    console.log(@blocks)

  positionBlocks: (newElemsCount) =>
    self = @
    $container = $('.block')
    $container.slice(Math.max($container.length - newElemsCount, 1)).each (()->
      min = Array.min(self.blocks)
      index = $.inArray(min, self.blocks)
      leftPos = self.margin+(index*(self.colWidth+self.margin))
      $(this).show()
      $(this).css({
        'left':leftPos+'px',
        'top':min+'px'
      })
      self.blocks[index] = min+$(this).outerHeight()+self.margin
    )
    console.log(@blocks)


  infiniteScroll: (logging) =>
    console.log('infiniteScroll called') if logging
    $('.pagination').hide()
    $('.block').hide()
    if document.URL.indexOf('home') > -1
      console.log('fast scrolling with infinity.js')
      $('.wrapper').imagesLoaded( =>
        @.setupBlocks()
        @.initPositionBlocks()
      )

      window.$el = $('.wrapper')
      window.listView = new infinity.ListView(window.$el)
      window.scrollReady = true

      $(window).scroll =>
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
            success: (data) =>
              $newElements = $(data).find('.block')
              $newElements.hide()
              window.listView.append($newElements)
              count = window.listView.pages[0].items.length
              console.log(count)
              console.log(window.listView.pages[0].items[count-1])

              window.scrollReady = true
              max = Array.max(@blocks)+600;
              console.log('max'+max)
              $('.loader').css({
                'top':max+'px'
              })
              $('.loader').show()
              $('.wrapper').imagesLoaded( =>
                $('.loader').hide()


                @.positionBlocks($newElements.length)
              )
            failure: (data) ->
              console.log('failed')
              window.scrollReady = true
          })
    else# normal slow scroll in other pages
      @.masonry()

      console.log('normal scrolling with infinite-scroll lib')
      $("#wrapper").infinitescroll({
        navSelector: "nav.pagination"               # selector for the paged navigation (it will be hidden)
        nextSelector: "nav.pagination a[rel=next]"  # selector for the NEXT link (to page 2)
        itemSelector: ".image"                        # selector for all items you'll retrieve
        #loading: {
        #  img: 'http://i.imgur.com/6RMhx.gif'
        #}
      },
      (newElements) ->
        $newElems = $( newElements )
        $container = $("#wrapper")
        $container.masonry( 'appended', $newElems )
        $container.imagesLoaded( ->
          $container.masonry()
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

