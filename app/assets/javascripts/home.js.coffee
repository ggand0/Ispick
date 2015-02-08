class @Home
  #instance = null
  constructor: (logging) ->
    $("body").off()
    $(window).off()
    imgLoad = imagesLoaded( $('.wrapper') )
    imgLoad.off('always')
    @scroll = new Scroll(logging)


  class HomePrivate
    constructor: (logging) ->
      @scroll = new Scroll(logging)

  @get: () ->
    return instance

  @set: (logging) ->
    #instance ?= new HomePrivate(logging)
    $("body").off()
    $(window).off()
    imgLoad = imagesLoaded( $('.wrapper') )
    imgLoad.off('always')
    instance = new HomePrivate(logging)