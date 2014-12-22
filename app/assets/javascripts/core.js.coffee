#= require 'component'

ready = ->
  # Dropdown:
  # click時にdialogを閉じる
  window.component = new Component()
  window.component.initDropdowns()

  # Modal:
  # 特定のクラスを持つモーダルは、背景を消して表示する
  window.component.initModals()

  # For autocompleting tags
  ###$("#q_tags_name_cont").tokenInput("/images/autocomplete.json", {
    crossDomain: false,
    prePopulate: $("#q_tags_name_cont").data("pre"),
    theme: "facebook"
  })###
  $("#q_tags_name_cont").autocomplete({
    source: '/tags/autocomplete.json',
  })

$(document).ready(ready)
$(document).on('page:load', ready)