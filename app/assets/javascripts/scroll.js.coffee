# Get the min value of an array
Array.min = (array) ->
  return Math.min.apply(Math, array)

# Get the max value of an array
Array.max = (array) ->
  return Math.max.apply(Math, array)

# Measure true height of desc-box
DESC_BOX_HEIGHT = 0
$(window).load( ->
  DESC_BOX_HEIGHT = $('.desc-box').eq(1).outerHeight()
  console.log('test'+DESC_BOX_HEIGHT)
)


# A class which have the public instance methods that align/scroll images on the screen
class @Scroll
  DEF_DESC_CLASS_NAME: 'desc-box' # The class name of description box divs
  DESC_BOX0_HEIGHT: 255
  DESC_BOX1_HEIGHT: 317
  DEF_COLUMN_WIDTH: 300
  DEF_IMAGE_HEIGHT: 300
  DEF_MARGIN: 20

  constructor: (logging) ->
    @mobile = false
    if ( /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent))
      console.log('from a mobile device')
      @DEF_MARGIN = 10
      @mobile = true


    @logging = logging        # Whether it writes logs or not
    @colCount=0
    @colWidth=0
    @margin=@DEF_MARGIN       # Margin width between two blocks
    @windowWidth=0
    @url = document.URL       # Get current URL for supporting browser back button
    @blocks = []              # Stores maximum heights from the top of each column
    @counter = 0
    @scrollHeight = 200       # The position it starts to load next images from the bottom of the screen
    @defHeight = 0            # The starting height where it starts to put image blocks
    @resize_rate = 1.0

    @$el = $('.wrapper')
    @listView = new infinity.ListView(@$el)
    @scrollReady = true

    # Set resize event
    $(window).resize(() =>
      if (timer != false)
        clearTimeout(timer)

      # Execute the function after it elapses 200ms
      timer = setTimeout(() =>
        @scrollReady = false
        @recalculatePositions()
        window.resizing = false
        @scrollReady = true
      , 500)
    )


  # [Not Used]Initialize masonry lib
  # Not necessary when using fastInfiniteScroll method
  masonry: () =>
    $container = $('.wrapper')
    $container.masonry({
       itemSelector: '.block',
       gutter: @DEF_MARGIN,
       gutterWidth: @DEF_MARGIN,
       animate: true,
       columnWidth: @DEF_COLUMN_WIDTH;
    })
    $('.block').css('margin-bottom', @DEF_MARGIN + 'px')
    $('.wrapper').hide()

    # call the layout method after all elements have been loaded
    $container.imagesLoaded( ->
      $('.wrapper').show()
      $container.masonry()
    )
    $container.masonry()

  isTop: ()=>
    topPages = ['/', '/signup', 'signin_with_password']
    for page in topPages
      return true if window.location.pathname == page
    return false


  # Calculate window size and column size
  setupBlocks: (pagination=false)=>
    @windowWidth = $(window).width()
    @colWidth = $('.block').outerWidth()
    @defHeight = $('.wrapper').offset().top
    #@defHeight += @margin # Add 20px margin so that it has correct gap

    if !@mobile
      @colCount = Math.floor(@windowWidth/(@colWidth+@margin))
    else
      @colCount = 2
      @colWidth = @windowWidth / 2.0 - @margin*1.5
      @resize_rate = @colWidth / (@DEF_COLUMN_WIDTH*1.0)

    if @mobile
      # Resize images
      # -@margin*3 since there's two rows
      #$('.image').css({width: @colWidth})
      #$('.block').css({width: @colWidth})
      self = @
      $('.block').filter(':not(.desc-box)').each( ->
        # Resize thick images only
        width = parseInt($(this).find('.width').text())
        $(this).find('img.image').css({ width: self.colWidth }) if width > self.colWidth
      )
      $('.desc-box').css({width: @windowWidth - @margin*2})
      $('.desc-box').css({width: @windowWidth - @margin*2})

      # Position desc boxes
      if @.isTop()
        $blocks = $('.block')
        $blocks.eq(0).css({
          'left':@margin+'px',
          'top':@defHeight+'px'
        })
        $blocks.eq(1).css({
          'left':@margin+'px',
          'top':@defHeight+$blocks.eq(0).outerHeight()+@margin+'px'

          # Since outerHeight method gives wrong values, use constants to get the height
          #'top':@defHeight+@DESC_BOX0_HEIGHT+@margin+'px'
        })
        #@defHeight = @defHeight + @DESC_BOX0_HEIGHT + @DESC_BOX1_HEIGHT + @margin*2
        @defHeight = @defHeight + $blocks.eq(0).outerHeight() + $blocks.eq(1).outerHeight() + @margin*2
        $blocks.eq(0).show()
        $blocks.eq(1).show()

    for i in [0..@colCount-1]
      @blocks.push(@defHeight)
    console.log(@blocks) if @logging


  # Re-calculate the positions of displayed images
  # on window resized event, or when some other items are re-rendered.
  recalculatePositions: () =>
    return if window.resizing
    window.resizing = true

    # Reset values
    @blocks = []
    @windowWidth = $(window).width()
    @defHeight = $('.wrapper').offset().top
    @defHeight += @margin # Add 20px margin so that it has correct gap
    if !@mobile
      @colCount = Math.floor(@windowWidth/(@colWidth+@margin))
    else
      @colCount = 2
      @colWidth = @windowWidth / 2.0 - @margin*2
      @resize_rate = @colWidth / (@DEF_COLUMN_WIDTH*1.0)

    if @mobile
      # Resize images
      #$('.image').css({width: @colWidth})
      #$('.block').css({width: @colWidth})
      self = @
      $('.block').filter(':not(.desc-box)').each( ->
        # Resize thick images only
        width = parseInt($(this).find('.width').text())
        $(this).find('img.image').css({ width: self.colWidth }) if width > self.colWidth
      )
      $('.desc-box').css({width: @windowWidth - @margin*2})

      if @.isTop()
        $blocks = $('.block')
        console.log($blocks.eq(0).hasClass(@DEF_DESC_CLASS_NAME))
        $blocks.eq(0).css({
          'left':@margin+'px',
          'top':@defHeight+'px'
        })
        $blocks.eq(1).css({
          'left':@margin+'px',
          #'top':@defHeight+$blocks.eq(0).outerHeight()+'px'

          # Since outerHeight method gives wrong values, use constants to get the height
          'top':@defHeight+@DESC_BOX0_HEIGHT+@margin+'px'
        })
        @defHeight = @defHeight + @DESC_BOX0_HEIGHT +
          @DESC_BOX1_HEIGHT + @margin*2
        $blocks.eq(0).show()
        $blocks.eq(1).show()
    for i in [0..@colCount-1]
      @blocks.push(@defHeight)


    # Re-calculate positions, loading past html elements from listView obj
    self = @
    count = 0
    for item in @listView.pages[0].items
      item.$el.each(()->
        # Skip description boxes since they're already positioned
        return if self.mobile and $(this).hasClass(self.DEF_DESC_CLASS_NAME)

        # Calculate and position a block div
        min = Array.min(self.blocks)
        index = $.inArray(min, self.blocks)
        leftPos = self.margin+(index*(self.colWidth+self.margin))
        if self.logging
          console.log(self.windowWidth+','+self.margin+','+self.colWidth+','+self.colCount)
          console.log(index+','+min)

        # Change css styles to position the div
        $(this).css({
          'left':leftPos+'px',
          'top':min+'px'
        })
        # Get the box's height
        if $(this).hasClass(self.DEF_DESC_CLASS_NAME)
          # Since this code handles the placement of initial images,
          # it may contain description boxes, which have specific heights.
          # As the heights of those boxes change by the amount of texts,
          # get their div heights directly at here.

          # Get the height including the margin
          height = $(this).outerHeight()
        else
          # Get the thumbnail's height from html
          # This data is rendered by Rails code, and read it on JS
          width = parseInt($(this).find('.width').text())
          height = parseInt($(this).find('.height').text())
          height = height * self.resize_rate if self.mobile and width >= self.colWidth
          height = self.DEF_IMAGE_HEIGHT if height == 0

        self.blocks[index] = min + height + self.margin

        # Debug outputs
        console.log(leftPos+','+height) if self.logging

        # Increment the counter
        count += 1
      )


  # Calculate initial images' positions
  initPositionBlocks: () =>
    self = @
    $blocks = $('.block')
    count = 0
    @colWidth = $blocks.outerWidth() if @colWidth is null


    # Position images one by one
    $blocks.each(()->
      # Skip description boxes since they're already positioned
      return if self.mobile and $(this).hasClass(self.DEF_DESC_CLASS_NAME)

      # Calculate and position a block div
      min = Array.min(self.blocks)
      index = $.inArray(min, self.blocks)
      leftPos = self.margin+(index*(self.colWidth+self.margin))

      if self.logging
        console.log(self.windowWidth+','+self.margin+','+self.colWidth+','+self.colCount)
        console.log(index+','+min)

      # Change css styles to position the div
      $(this).css({
        'left':leftPos+'px',
        'top':min+'px'
      })
      $(this).show()

      # Get the box's height
      if $(this).hasClass(self.DEF_DESC_CLASS_NAME)

        # Since this code handles the placement of initial images,
        # it may contain description boxes, which have specific heights.
        # As the heights of those boxes change by the amount of texts,
        # get their div heights directly at here.

        # Get the height including the margin
        height = $(this).outerHeight()
      else
        # Get the thumbnail's height from html
        # This data is rendered by Rails code, and read it on JS
        width = parseInt($(this).find('.width').text())
        height = parseInt($(this).find('.height').text())
        height = height * self.resize_rate if self.mobile and width >= self.colWidth
        height = self.DEF_IMAGE_HEIGHT if height == 0


      self.blocks[index] = min + height + self.margin

      # Debug outputs
      console.log(leftPos+','+height) if self.logging

      # Increment the counter
      count += 1
    )
    console.log(@blocks) if @logging
    @scrollReady = true


  # Calculate and position newly loaded images
  positionBlocks: (newElemsCount) =>
    self = @
    # Sometimes, especially after using the datepicker,
    # colWidth variable gets null. Re-initialize it if it detects null.
    @colWidth = $('.block').outerWidth() if @colWidth is null
    $container = $('.block')

    # Position images one by one.
    # Get newly added elements only
    $container.slice(Math.max($container.length - newElemsCount, 1)).each (()->
      min = Array.min(self.blocks)
      index = $.inArray(min, self.blocks)
      leftPos = self.margin+(index*(self.colWidth+self.margin))

      if self.logging
        console.log(self.windowWidth+','+self.margin+','+self.colWidth+','+self.colCount)
        console.log(index+','+min)

      # Change css styles to position the div
      $(this).css({
        'left':leftPos+'px',
        'top':min+'px'
      })
      $(this).show()

      width = parseInt($(this).find('.width').text())
      height = parseInt($(this).find('.height').text())
      height = height * self.resize_rate if self.mobile and width >= self.colWidth
      height = self.DEF_IMAGE_HEIGHT if height == 0

      console.log(leftPos+','+height) if self.logging
      self.blocks[index] = min+height+self.margin
    )
    console.log(@blocks) if @logging


  # Update loading icon's position
  updateSpinner: ()=>
    max = Array.max(@blocks)
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
    @scrollReady = false

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

        # Display loading gif icon
        @.updateSpinner()
        $('#loader').show()

        # Add event to position newly loaded images
        #$('.wrapper').imagesLoaded( =>
        imgLoad = imagesLoaded( $('.wrapper') )
        imgLoad.on('always', (instance) =>
          # Append them to the listView array
          @listView.append($newElements)
          count = @listView.pages[0].items.length
          console.log(count+': '+@listView.pages[0].items[count-1]) if @logging

          console.log('images loaded') if @logging
          $('#loader').hide()

          # Resize elements if mobile devices
          if @mobile
            self = @
            $('.block').filter(':not(.desc-box)').each( ->
              # Resize thick images only
              width = parseInt($(this).find('.width').text())
              $(this).find('img.image').css({ width: self.colWidth }) if width > self.colWidth
            )
            @.positionBlocks($newElements.length)
          else
            @.positionBlocks($newElements.length)

          # Now we can load the next set of images
          @scrollReady = true
        )
      failure: (data) ->
        console.log('failed') if @logging
        @scrollReady = true
    })



  # Align images for pagination
  alignImages: ()=>
    console.log('pagination with dynamic aligning') if @logging
    $('#loader').hide()

    # Initialize basic values
    $('.block').hide()
    @.setupBlocks(true)
    @.updateSpinner()

    # Position images after image files are loaded
    #$('.wrapper').imagesLoaded( =>
    imgLoad = imagesLoaded( $('.wrapper') )
    imgLoad.on('always', (instance) =>
      # Calculate positions of initial images
      console.log('images loaded') if @logging
      @initPositionBlocks()

      max = Array.max(@blocks)
      console.log(max)
      $('.pagination-footer').css({
        'top': max + 'px',
        'position': 'absolute',
        'visibility': 'visible'
      })
      $('.pagination-footer').show()
      console.log($('.pagination-footer').css('top'))
    )


  # Infinite scrolling with Infinity.js
  fastInfiniteScroll: ()=>
    console.log('fast scrolling with infinity.js') if @logging

    # Initialization
    @scrollReady = false
    $('.block').hide()
    @.setupBlocks()
    @.updateSpinner()

    # Position images after image files are loaded
    #$('.wrapper').imagesLoaded( =>
    imgLoad = imagesLoaded( $('.wrapper') )
    imgLoad.on('always', (instance) =>
      # Append initial images to the listView array
      @listView.append($('.block'))
      count = @listView.pages[0].items.length
      console.log(count+': '+@listView.pages[0].items[count-1]) if @logging

      # Calculate positions of initial images
      console.log('images\' been loaded') if @logging
      $('#loader').hide()
      @initPositionBlocks()
    )


    # =================================
    #            SCROLL EVENTS
    # =================================
    # Add event to load images when there's no scroll bars
    $(window).on('mousewheel', (e) =>
      # Do nothing when it's not ready
      #console.log(@scrollReady)
      return if @scrollReady == false

      # Return if the instance wasn't created on the current page
      current_url = document.URL
      return if current_url != @url

      # Load new images if there's no scroll bars
      hasScrollBar = $(document).height() > $(window).height()
      url = $('nav.pagination a[rel=next]').attr('href')
      if e.originalEvent.deltaY > 0 and !hasScrollBar
        console.log('without scrollbar') if @logging
        @.loadImages(url)
    )

    # Add event to load images when it's scrolled to the bottom
    $(window).scroll( =>
      # Do nothing when it's not ready
      console.log('@scrollReady:'+@scrollReady)
      #console.log('@scrollReady==false:'+(@scrollReady == false))
      return if @scrollReady == false

      # Return if the instance wasn't created on the current page
      current_url = document.URL
      return if current_url != @url

      url = $('nav.pagination a[rel=next]').attr('href')
      console.log(url) if @logging
      if url and $(window).scrollTop() > $(document).height() - $(window).height() - @scrollHeight
        console.log('with scrollbar') if @logging
        @.loadImages(url)
    )




  # [Not Used]Infinite scrolling using Masonry.js
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

