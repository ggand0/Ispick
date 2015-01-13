# Not in use @14/09/26

require "#{Rails.root}/app/services/target_images_service"

namespace :feature do
  desc "Reset all convnet features and re-extract them"
  task reset_convnet: :environment do
    if Rails.env.production?
      puts 'Please implement specific conditions to select images.'
      puts 'Exiting...'
      return
    end

    Image.all.each_with_index do |image, count|
      unless image.feature.nil?
        image.feature.convnet_feature = nil
      end
      Resque.enqueue(ImageFeature, 'Image', image.id)
      puts "#{count} / #{Image.count}" if count % 100 == 0
    end
    puts 'Image DONE!'

    TargetImage.all.each_with_index do |image, count|
      unless image.feature.nil?
        image.feature.convnet_feature = nil

      end
      Resque.enqueue(ImageFeature, 'TargetImage', image.id)
      puts "#{count} / #{TargetImage.count}" if count % 100 == 0
    end
    puts 'TargetImage DONE!'
    puts 'DONE!'
  end

  desc "Extract face features of a TargetImage record"
  task face_target: :environment do
    raise NotImplementedError

    target_image = TargetImage.find(ENV["TARGET_IMAGE_ID"])
    puts 'DONE!'
  end

  desc "Extract face features of all TargetImage records"
  task face_targets: :environment do
    target_images = TargetImage.all
    target_images.each do |target_image|
      # Skip if it's already extracted
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

  desc "Extract face features of all Image records"
  task face_images: :environment do
    images = Image.all
    images.each do |image|
      # Skip if already extracted
      next unless image.feature.nil?

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
