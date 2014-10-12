# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#= require 'component'

app = angular.module('Ispick', ['infinite-scroll'])
app.controller('ImageCtrl', ($scope, Image) ->
  ###$scope.images = [1, 2, 3, 4, 5, 6, 7, 8]
  $scope.loadMore = () ->
    last = $scope.images[$scope.images.length - 1]
    for i in [0..8]
      $scope.images.push(last + i)###
  $scope.image = new Image()
)

app.factory('Image', () ->
  class Image
    constructor: () ->
      @items = []
      @busy = false
      console.log(@items)

    nextPage: () =>
      console.log(@busy)
      return if @busy
      @busy = true

      url = $('nav.pagination a[rel=next]').attr('href')
      console.log(url)
      $.getScript(url+".js")
      $.ajax({
        cache: false,
        url: url,
        type: 'GET',
        dataType: 'json',
        success: (data) =>
          @busy = false
          console.log('success')
          console.log(data)
          console.log(@busy)

          for i in [0..data.length-1]
            @items.push(data[i])
        failure: (data) ->
          console.log('failed')
      })
)######


ready = ->
  component = new Component()

  # Initialize buttons related to clipping
  component.initButtons()


  # Initialize infinite scroll
  component.infiniteScroll(true)


  # Display the calender (Datepicker)
  component.initCalender()


  # Popovers: close popover on click wherever except popover windows
  component.initPopovers()

$(document).ready(ready)
$(document).on('page:load', ready)
