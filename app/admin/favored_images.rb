ActiveAdmin.register FavoredImage do
  index do
    column :src_url
    column :page_url
    column :original_url
    column :image_id
    column :created_at

    actions
  end
end