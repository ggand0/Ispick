module ImageBoardsHelper
  # paramsで指定されたdelivered_imageが
  # image_boardに既に登録されているか確認する
  def check_existed(board_id, delivered_image_id)
    image_board = ImageBoard.find(board_id)
    delivered_image = DeliveredImage.find(delivered_image_id)

    included = false
    #if not image_board.favored_images.empty?

    included = image_board.favored_images.any? do |f|
      #
      f.delivered_image.id == delivered_image_id# if f.delivered_image
    end
    #end

    puts included
    included
  end
end
