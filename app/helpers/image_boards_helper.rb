#-*- coding: utf-8 -*-
module ImageBoardsHelper

  # paramsで指定されたimageが
  # image_boardに既に登録されているか確認する
  # @param [Integer] 確認するImageBoardのid
  # @param [Integer] 確認するImageのid
  # @return [Boolean] ImageがImageBoardに登録されているかどうか
  def check_existed(board_id, image_id)
    image_board = ImageBoard.find(board_id)
    image = Image.find(image_id)

    included = false
    included = image_board.favored_images.any? do |f|
      # idが等しければ含まれていると判断
      f.image.id == image_id if f.image
    end

    included
  end
end
