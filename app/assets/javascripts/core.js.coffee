#= require 'component'

$ ->
  # Dropdown:
  # click時にdialogを閉じる
  window.Component.addDropdownEvents()

  # Modal:
  # 特定のクラスを持つモーダルは、背景を消して表示する
  window.Component.addModalEvents()