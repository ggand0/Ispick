json.array!(@delivered_images) do |delivered_image|
  json.extract! delivered_image, :id, :title, :caption, :src_url
  json.url delivered_image_url(delivered_image, format: :json)
end
