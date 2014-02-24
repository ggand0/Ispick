require "#{Rails.root}/app/services/target_images_service"

namespace :feature do
  desc "対象となる１つのTargetImageモデルの顔特徴量を抽出する"
  task face_target: :environment do
    raise NotImplementedError

    target_image = TargetImage.find(ENV["TARGET_IMAGE_ID"])
    puts 'DONE!'
  end

  desc "TargetImageモデル全てに対して顔特徴量を抽出する"
  task face_targets: :environment do
    target_images = TargetImage.all
    target_images.each do |target_image|
      # 既に抽出済みの場合は飛ばす
      if not target_image.face_feature.nil?
        next
      end

      service = TargetImagesService.new
      face_feature = service.prefer(target_image)
      json_string = face_feature[:result].to_json
      target_image.update_attributes({ face_feature: json_string })

      puts (target_image.id - TargetImage.first.id + 1).to_s + ' / ' + TargetImage.count.to_s
    end

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
