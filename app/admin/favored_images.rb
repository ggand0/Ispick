ActiveAdmin.register FavoredImage do
  index do
    actions

    column :id
    column :src_url
    column :page_url
    column :original_url
    column :image_id
    column :created_at
  end

  show do |image|
    attributes_table do
      row 'FavoredImage' do
        image_tag image.data.url(:thumb)
      end
    end
  end
end