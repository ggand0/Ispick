module ImageBoardsHelper

  # paramsで指定されたdelivered_imageが
  # image_boardに既に登録されているか確認する
  # @param [Integer] 確認するImageBoardのid
  # @param [Integer] 確認するDeliveredImageのid
  # @return [Boolean] DeliveredImageがImageBoardに登録されているかどうか
  def check_existed(board_id, delivered_image_id)
    image_board = ImageBoard.find(board_id)
    delivered_image = DeliveredImage.find(delivered_image_id)

    included = false
    included = image_board.favored_images.any? do |f|
      # idが等しければ含まれていると判断
      f.delivered_image.id == delivered_image_id if f.delivered_image
    end

    included
  end
end
