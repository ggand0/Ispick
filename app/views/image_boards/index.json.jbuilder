json.array!(@image_boards) do |image_board|
  json.extract! image_board, :id
  json.url image_board_url(image_board, format: :json)
end
