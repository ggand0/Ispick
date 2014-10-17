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
      window.blocks.push(defHeight)
    console.log(window.blocks) if @logging


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
      #$img = $(this).find('img')
      #height = $img.height()
      height = parseInt($(this).find('.height').text())
      height = 300 if height == 0
      console.log(height) if @logging
      window.blocks[index] = min+height+self.margin
    )
    console.log(window.blocks) if @logging

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
      height = parseInt($(this).find('.height').text())
      height = 300 if height == 0
      console.log(height) if @logging
      window.blocks[index] = min+height+self.margin
    )
    console.log(window.blocks) if @logging

  # Update loading icon's position
  updateSpinner: ()=>
    max = Array.max(window.blocks)
    $('#loader').css({
      'top':max+'px'
      'left':(@colCount/2)*@colWidth+'px'
    })


  infiniteScroll: () =>
    console.log('infiniteScroll called') if @logging
    $('.pagination').hide()
    @.fastInfiniteScroll()
    ###if document.URL.indexOf('home') > -1
      console.log('home')
    else# normal slow scroll in other pages
      console.log('other than home')###


  fastInfiniteScroll: ()=>
    console.log('fast scrolling with infinity.js') if @logging
    $('.block').hide()
    @.setupBlocks()
    @.updateSpinner()

    $('.wrapper').imagesLoaded( =>
      console.log('images loaded') if @logging
      $('#loader').hide()
      @initPositionBlocks()
    )

    window.$el = $('.wrapper')
    window.listView = new infinity.ListView(window.$el)
    window.scrollReady = true

    $(window).scroll =>
      #console.log(window.scrollReady)
      return if window.scrollReady == false
      url = $('nav.pagination a[rel=next]').attr('href')
      console.log(url) if @logging

      if url and $(window).scrollTop() > $(document).height() - $(window).height() - 50
        console.log('Fetching...') if @logging
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
            console.log(count+': '+window.listView.pages[0].items[count-1]) if @logging

            window.scrollReady = true
            @.updateSpinner()

            $('#loader').show()
            $('.wrapper').imagesLoaded( =>
              console.log('images loaded') if @logging
              $('#loader').hide()
              @.positionBlocks($newElements.length)
            )
          failure: (data) ->
            console.log('failed') if @logging
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

