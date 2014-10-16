Array.min = (array) ->
  return Math.min.apply(Math, array)
Array.max = (array) ->
  return Math.max.apply(Math, array)

getNatural = ($mainImage) ->
  mainImage = $mainImage[0]
  d = {}

  #if mainImage.naturalWidth === undefined
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
  constructor: ->
    #console.log('scroll constructor called')
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
      #console.log(defHeight)
      window.blocks.push(defHeight)
    console.log(window.blocks)

  getImageHeight: (img, index, min, margin)=>
    deferred = new $.Deferred()
    height=0
    console.log(index+' '+min+' '+margin)
    #console.log(img)
    #console.log($(img).height())
    $(img).on('load', ()->
      height = $(this).height()
      #return deferred.resolve(height)
      console.log(height)
      window.blocks[index] = min+height+margin

      deferred.resolve({ height: height })
      #return deferred.promise(height)
    ).each( ->
      $(this).load() if (this.complete)
    )
    #return deferred.promise(height)
    window.promisesArray.push(deferred.promise)

  doTask: (i, next)=>
    console.log('doTasks')
    self = @
    min = Array.min(window.blocks)
    index = $.inArray(min, window.blocks)
    leftPos = self.margin+(index*(self.colWidth+self.margin))

    block = $('.block').eq(i)
    block.css({
      'left':leftPos+'px',
      'top':min+'px'
    })
    block.show()
    $img = block.find('img')
    console.log($img)
    console.log(next)
    $img.on('load', ()->
      height = $(this).height()
      console.log(height)
      window.blocks[index] = min+height+self.margin
      next()
    )
    time = Math.floor(Math.random()*3000)
    setTimeout(->
      height = $(this).height()
      console.log(height)
      window.blocks[index] = min+height+self.margin
      next()
    ,time)
  createTask: (num)=>
    return (next)=>
      @.doTask(num, next)


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
      $img = $(this).find('img')
      height = $img.height()
      console.log(height)
      window.blocks[index] = min+height+self.margin
      #$img.on('load', ()->
      #  height = $(this).height()
      #  console.log(height)
      #  window.blocks[index] = min+height+self.margin
    )

    ###tasks = [0..$('.block').length-1]
    console.log(tasks)
    for i in tasks
      $(document).queue('tasks', @.createTask(tasks[i]))
    $(document).queue('tasks', ()->
      console.log('all done')
    )
    $(document).dequeue('tasks')###

    console.log(window.blocks)
    #return $.when.apply(undefined, promises).promise()


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
      $('.wrapper').imagesLoaded( =>
        $('#loader').hide()
        console.log('image loaded')
        @.initPositionBlocks()
      )
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

