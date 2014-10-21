xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "Ispick"
    xml.description "images with the tag 'aqua eyes'"

    for image in @images_all
      xml.item do
        xml.title image.title
        xml.description image.caption
        xml.posted_at image.posted_at
        xml.thumb_url image.src_url
        xml.page_url image.page_url
        xml.original_url image.original_url
      end
    end
  end
end