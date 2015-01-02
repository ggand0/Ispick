Array.min = (array) ->
  return Math.min.apply(Math, array)
Array.max = (array) ->
  return Math.max.apply(Math, array)

getNatural = ($mainImage) ->
  mainImage = $mainImage[0]
  d = {}
  if mainImage.naturalWidth is undefined
    i = new Image()
    i.src = mainImage.src
    d.oWidth = i.width
    d.oHeight = i.height
  else
    d.oWidth = mainImage.naturalWidth
    d.oHeight = mainImage.naturalHeight
  return d




class @Scroll
  constructor: (logging) ->
    @logging = logging
    @colCount=0
    @colWidth=0
    @margin=20
    @windowWidth=0
    window.blocks=[]
    window.promisesArray=[]
    @counter = 0
    @scrollHeight = 200
    @defHeight = 0          # Starting height

    # Get GET parameters(not used)
    @GET = {}
    document.location.search.replace(/\??(?:([^=]+)=([^&]*)&?)/g, =>
      decode = (s) =>
        return decodeURIComponent(s.split("+").join(" "))
      @GET[decode(arguments[1])] = decode(arguments[2])
    )


  # Initialize masonry lib
  # Not necessary when using fastInfiniteScroll method
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


  # Calculate window size and column size
  setupBlocks: ()=>
    @windowWidth = $(window).width()
    @colWidth = $('.block').outerWidth()
    @colCount = Math.floor(@windowWidth/(@colWidth+@margin))
    for i in [0..@colCount-1]
      defHeight = $('.wrapper').offset().top
      window.blocks.push(defHeight)
    console.log(window.blocks) if @logging


  # Calculate initial images' positions
  initPositionBlocks: ()=>
    self = @
    @colWidth = $('.block').outerWidth() if @colWidth is null
    $('.block').each(()->
      min = Array.min(window.blocks)
      index = $.inArray(min, window.blocks)
      leftPos = self.margin+(index*(self.colWidth+self.margin))
      if @logging
        console.log(self.windowWidth+','+self.margin+','+self.colWidth+','+self.colCount)
        console.log(index+','+min)
      $(this).css({
        'left':leftPos+'px',
        'top':min+'px'
      })
      $(this).show()

      # Get thumbnail's height from html
      # This data is rendered by Rails code, and read it on JS
      height = parseInt($(this).find('.height').text())
      height = 300 if height == 0
      console.log(leftPos+','+height) if self.logging
      window.blocks[index] = min+height+self.margin
    )
    console.log(window.blocks) if @logging

  # Calculate and position newly loaded images
  positionBlocks: (newElemsCount) =>
    self = @
    # Sometimes, especially after using the datepicker,
    # colWidth variable gets null. Re-initialize it if it detects null.
    @colWidth = $('.block').outerWidth() if @colWidth is null
    $container = $('.block')
    $container.slice(Math.max($container.length - newElemsCount, 1)).each (()->
      min = Array.min(window.blocks)
      index = $.inArray(min, window.blocks)
      leftPos = self.margin+(index*(self.colWidth+self.margin))
      if @logging
        console.log(self.windowWidth+','+self.margin+','+self.colWidth+','+self.colCount)
        console.log(index+','+min)
      $(this).show()
      $(this).css({
        'left':leftPos+'px',
        'top':min+'px'
      })
      height = parseInt($(this).find('.height').text())
      height = 300 if height == 0
      console.log(leftPos+','+height) if self.logging
      window.blocks[index] = min+height+self.margin
    )
    console.log(window.blocks) if @logging


  # Update loading icon's position
  updateSpinner: ()=>
    max = Array.max(window.blocks)
    #max = Array.max(window.blocks) - 100
    $('#loader').css({
      'top':max+'px'
      'left':(@colCount/2)*@colWidth+'px'
    })


  # Calculate images' position and add primary events
  infiniteScroll: () =>
    console.log('infiniteScroll called') if @logging
    $('.pagination').hide()
    @.fastInfiniteScroll()


  # Load next images to display
  loadImages: (url) =>
    console.log('Fetching...') if @logging
    # Prevent loading next images until current loading is done
    window.scrollReady = false

    # Get and execute javascript template of the current page
    $.getScript(url)

    # Get next images
    $.ajax({
      cache: false,
      url: url,
      type: 'GET',
      dataType: 'html',

      success: (data) =>
        # Get image divs
        $newElements = $(data).find('.block')
        $newElements.hide()

        # Append them to the listView array
        window.listView.append($newElements)
        count = window.listView.pages[0].items.length
        console.log(count+': '+window.listView.pages[0].items[count-1]) if @logging

        # Display loading gif icon
        @.updateSpinner()
        $('#loader').show()

        # Add event to position newly loaded images
        $('.wrapper').imagesLoaded( =>
          console.log('images loaded') if @logging
          $('#loader').hide()
          @.positionBlocks($newElements.length)
        )

        # Now we can load next images
        window.scrollReady = true
      failure: (data) ->
        console.log('failed') if @logging
        window.scrollReady = true
    })

  # Infinite scrolling with Infinity.js
  fastInfiniteScroll: ()=>
    console.log('fast scrolling with infinity.js') if @logging
    # Initialize
    $('.block').hide()
    @.setupBlocks()
    @.updateSpinner()

    # Position images after image files are loaded
    $('.wrapper').imagesLoaded( =>
      console.log('images loaded') if @logging
      $('#loader').hide()
      @initPositionBlocks()
    )

    # Initialize window variables
    window.$el = $('.wrapper')
    window.listView = new infinity.ListView(window.$el)
    window.scrollReady = true


    # Add event to load images when there's no scroll bars
    $(window).on('mousewheel', (e) =>
      # Do nothing when it's not ready
      return if window.scrollReady == false

      # Load new images if there's no scroll bars
      hasScrollBar = $(document).height() > $(window).height()
      url = $('nav.pagination a[rel=next]').attr('href')
      if e.originalEvent.deltaY > 0 and !hasScrollBar
        console.log('without scrollbar') if @logging
        @.loadImages(url)
    )

    # Add event to load images when it's scrolled to the bottom
    $(window).scroll =>
      #console.log(window.scrollReady) if @logging
      return if window.scrollReady == false

      url = $('nav.pagination a[rel=next]').attr('href')
      console.log(url) if @logging
      if url and $(window).scrollTop() > $(document).height() - $(window).height() - @scrollHeight
        console.log('with scrollbar') if @logging
        @.loadImages(url)



  # Infinite scrolling using Masonry.js
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

