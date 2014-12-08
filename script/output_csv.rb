# coding: utf-8
#require 'csv'

module OutputCSV

  # 画像を抽出して保存
  def self.output_images()
    CSV.open("#{Rails.root}/csv/Images.csv","wb") do |csv|
      row = ["image_id","page_url","original_width","original_height","artist","tags(separate by ';')"]
      csv << row
    
      Image.all.each do |image|
        row = []
        row.push(image.id)
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
  
  def self.output_fi()
    CSV.open("#{Rails.root}/csv/ImageBoards.csv","wb") do |csv|
      row = ["board_id","image_id"]
      csv << row
      FavoredImage.all.each do |fi|
        row=[]
        row.push(fi.image_board_id)
        row.push(fi.image_id)
        csv << row
      end
    
    end
  end

end
