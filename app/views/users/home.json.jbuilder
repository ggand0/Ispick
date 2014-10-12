json.array!(@images) do |image|
  #json.extract! image, :id, :title, created_at
  json.id image.id
  json.title image.title
  json.created_at image.created_at
  json.posted_at image.posted_at
  json.thumb image.data.url(:thumb)
  json.url image.data.url
end
