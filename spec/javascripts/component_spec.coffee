#= require spec_helper
#= require 'component'

describe "Component class", ->
  it 'has necessary functions', (done) ->
    component = new Component()
    expect(component.initButtons).not.toBe(null)

  describe "infiniteScroll function", ->
    it "call", ->
      loadFixtures("home.html")
      component = new Component()

      #spy = spyOn($.fn, 'infiniteScroll')
      spy = spyOn($.fn, 'find')
      component.infiniteScroll(true)
      expect(spy).toHaveBeenCalled()

  describe "initCalender function", ->
    it 'should do what...', (done) ->
      loadFixtures("home.html")
      component = new Component()

      #expect($(".input-group.date")).toBeSelected()
      spy = spyOn($.fn, 'find')
      component.initCalender()
      expect(spy).toHaveBeenCalledWith('.input-group.date')
