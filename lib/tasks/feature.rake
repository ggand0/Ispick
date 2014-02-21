namespace :feature do
  desc "TargetImageモデルの顔特徴量を抽出する"
  task face: :environment do
    target_image = TargetImage.find(ENV["TARGET_IMAGE_ID"])

  end
end
