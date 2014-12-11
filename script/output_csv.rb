# coding: utf-8
#require 'csv'

module OutputCSV

  # 画像を抽出して保存
  def self.output_images(src)
    CSV.open("#{Rails.root}/csv/Images.csv","wb") do |csv|
      row = ["image_id","src","page_url","original_width","original_height","artist","tags(separate by ';')"]
      csv << row
    
      if(src=="all") then
        images = Image.all
      else
        images = Image.where(site_name: src)
      end
    
      images.each do |image|
        row = []
        row.push(image.id)
        row.push(image.site_name)
        row.push(image.page_url)
        row.push(image.original_width)
        row.push(image.original_height)
        row.push(image.artist)
        
        tags = ""
        ImagesTag.where(image_id: image.id).each do |tag|
            tags = tags + Tag.find(tag.tag_id).name + ";"
        end
        row.push(tags)     
        csv << row
      end

    end
  end
  
  def self.output_fi(src)
    CSV.open("#{Rails.root}/csv/ImageBoards.csv","wb") do |csv|
      row = ["board_id","image_id"]
      csv << row
      FavoredImage.where(site_name:src).each do |fi|
        row=[]
        row.push(fi.image_board_id)
        row.push(fi.image_id)
        csv << row
      end
    
    end
  end

end
