#= require 'component'

$ ->
  # Dropdown:
  # click時にdialogを閉じる
  component = new Component()
  component.initDropdowns()

  # Modal:
  # 特定のクラスを持つモーダルは、背景を消して表示する
  component.initModals()