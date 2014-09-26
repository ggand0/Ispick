# Not in use @14/09/26

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
      if not target_image.feature.nil?
        next
        puts 'continued.'
      end

      service = TargetImagesService.new
      face_feature = service.prefer(target_image)
      json_string = face_feature[:result].to_json
      feature = Feature.new(face: json_string)
      Feature.transaction do
        feature.save!
        TargetImage.transaction do
          target_image.feature = feature
        end
      end

      puts (target_image.id - TargetImage.first.id + 1).to_s + ' / ' + TargetImage.count.to_s
    end

    puts 'DONE!'
  end

  desc "Imageモデル全てに対して顔特徴量を抽出する"
  task face_images: :environment do
    images = Image.all
    images.each do |image|
      # 既に抽出済みの場合は飛ばす
      if not image.feature.nil?
        next
      end

      service = TargetImagesService.new
      face_feature = service.prefer(image)
      json_string = face_feature[:result].to_json
      feature = Feature.new(face: json_string)
      Feature.transaction do
        feature.save!
        Image.transaction do
          image.feature = feature
        end
      end

      puts (image.id - Image.first.id + 1).to_s + ' / ' + Image.count.to_s
    end

    puts 'DONE!'
  end
end
