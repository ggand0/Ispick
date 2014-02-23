require "#{Rails.root}/app/services/target_images_service"

namespace :feature do
  desc "TargetImageモデルの顔特徴量を抽出する"
  task face_target: :environment do
    target_image = TargetImage.find(ENV["TARGET_IMAGE_ID"])
    puts 'DONE!'
  end

  desc "Imageモデル全てに対して顔特徴量を抽出する"
  task face_images: :environment do
    images = Image.all
    images.each do |image|
      # 既に抽出済みの場合は飛ばす
      if not image.face_feature.nil?
        next
      end

      service = TargetImagesService.new
      face_feature = service.prefer(image)
      json_string = face_feature[:result].to_json
      image.update_attributes({ face_feature: json_string })

      puts (image.id - Image.first.id + 1).to_s + ' / ' + Image.count.to_s
    end

    puts 'DONE!'
  end
end
