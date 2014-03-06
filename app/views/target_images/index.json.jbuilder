json.array!(@target_images) do |target_image|
  json.extract! target_image, :id, :title
  json.url target_image_url(target_image, format: :json)
end
