$ ->
  # Dropdown:
  # click時にdialogを閉じる
  $('.dropdown-user').click (e) ->
    $("body").trigger("click")

  # Modal:
  # 特定のクラスを持つモーダルは、背景を消して表示する
  $('.modal-avatar').on('show.bs.modal hide.bs.modal', (e) ->
    $('body').toggleClass('modal-color-none')
  )