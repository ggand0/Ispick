#= require spec_helper
#= require 'clip'
#= require 'users'

describe "users.coffee", ->
  it "call the function", ->
    #spy = sinon.spy(jQuery, 'ajax')
    #spy = sinon.spy(global.Clip.addClipEvents)
    spy = sinon.spy(global.Clip, 'addClipEvents')
    global.Clip.addClipEvents()
    #spy()
    console.log(spy.called)
    expect(spy.called).to.equal(true)
