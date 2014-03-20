#-*- coding: utf-8 -*-
require "#{Rails.root}/app/services/target_images_service"
require "#{Rails.root}/app/helpers/application_helper"
include ApplicationHelper

module Deliver
  MAX_DELIVER_NUM = 100
  MAX_DELIVER_SIZE = 100*1024*1024

  def self.deliver_from_target(user, target_image, count_all, count)
    # 推薦イラストを取得
    puts 'Processing ' + (count+1).to_s + ' / ' + count_all.to_s
    service = TargetImagesService.new
    result = service.get_preferred_images(target_image)
    puts 'Preferred images: ' + result[:images].count.to_s

    # 既に配信済みの画像である場合はskip
    puts 'User.delivered_images.count: ' + user.delivered_images.count.to_s
    result[:images].reject! { |x| user.delivered_images.any?{ |d| d.src_url == x[:image].src_url }}
    puts 'Unique images: ' + result[:images].count.to_s

    # 最大配信数に絞る（推薦度の高い順に残す）
    if result[:images].count > MAX_DELIVER_NUM
      puts 'Removing excessed images...'
      #puts MAX_DELIVER_NUM
      puts result[:images].class
      result[:images] = result[:images].take MAX_DELIVER_NUM
    end
    puts 'Final delivered images: ' + result[:images].count.to_s

    # User.delivered_imagesへ追加
    c=0
    result[:images].each do |i|
      im = i[:image]
      file = File.open(im.data.path)
      image = DeliveredImage.create(title: im.title, src_url: im.src_url)
      if image
        # file.close出来てもuser.delivered_imagesはclose出来ない
        # (userがglobalから参照される限りuser.delivered_images[i].dataも参照される)ので、
        # ファイルへの参照数がタスク終了するまで増加していくことに注意。
        # 開いているファイル数がulimitで設定されている数を超えると'Too many open files...'エラー
        image.data = file
        user.delivered_images << image# ここがcritical
        user.save
      end
      file.close

      c+=1
      puts '- Creating delivered_images:' + c.to_s + ' / ' + result[:images].count.to_s if c % 10 == 0
    end

    # １ユーザーの最大容量を超えていたら古い順に削除
    Deliver.delete_excessed_records(user.delivered_images, MAX_DELIVER_SIZE)
    puts 'Remain delivered_images:' + user.delivered_images.count.to_s

    # 最終配信日時を記録
    target_image.last_delivered_at = DateTime.now
  end

  def self.delete_excessed_records(images, max_size)
    delete_count = 0
    image_size = get_total_size(images)

    # 削除する数を計算（順に消してシミュレートしていく）
    images.order(:created_at).each do |i|
      image_size -= i.data.size
      delete_count += 1
      break if image_size <= max_size
    end

    # 古い順(created_atのASC)
    images.limit(delete_count).order(:created_at).destroy_all
    images
  end
end