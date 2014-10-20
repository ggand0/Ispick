#= require 'component'

ready = ->
  # Dropdown:
  # click時にdialogを閉じる
  window.component = new Component()
  window.component.initDropdowns()

  # Modal:
  # 特定のクラスを持つモーダルは、背景を消して表示する
  window.component.initModals()

$(document).ready(ready)
$(document).on('page:load', ready)