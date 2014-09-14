#= require 'component'


$ ->
  # Board追加dialogの更新
  component = new Component()
  component.initBoards()

  # Popoverに変更したので今は使用していない:
  #$('.user_boards').on("click", (e, data, status, xhr) ->
  #  $('#modal-board').modal('hide')
  #)

