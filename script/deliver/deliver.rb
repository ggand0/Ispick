#-*- coding: utf-8 -*-
require "#{Rails.root}/app/services/target_images_service"
require "#{Rails.root}/app/helpers/application_helper"
include ApplicationHelper

module Deliver
  # 1回の配信で、1ユーザーに対して配信する推薦イラストの数
  MAX_DELIVER_NUM = 100
  # [MB]
  MAX_DELIVER_SIZE = 200

  def self.deliver(user_id)
    count = 0
    delivered = []
    user = User.find(user_id)
    count_all = user.target_images.length

    user.target_words.each do |t|
      Deliver.deliver_from_word(user, t)
    end
    user.target_images.each do |t|
      Deliver.deliver_from_image(user, t, count_all, count)
      count += 1
    end

    # １ユーザーの最大容量を超えていたら古い順に削除
    Deliver.delete_excessed_records(user.delivered_images, MAX_DELIVER_SIZE)
    puts 'Remain delivered_images:' + user.delivered_images.count.to_s
  end

  def self.contains_word(image, target_word)
    word = target_word.person.name
    image.tags.each do |tag|
      return true if tag.name.include?(word)
    end
    image.title.include?(word) or image.caption.include?(word)
  end

  # User.delivered_imagesへ追加
  def self.deliver_images(user, images, target)
    c = 0
    images.each do |im|
      image = DeliveredImage.create(
        title: im.title,
        caption: im.caption,
        src_url: im.src_url,
        data: im.data
      )
      #im.tags.each { |tag| image.tags << tag }
      image.targetable = target# target_image / target_word
      if image
        user.delivered_images << image# ここがcritical
        user.save
      end
      c += 1
      puts '- Creating delivered_images:' + c.to_s + ' / ' +
        images.count.to_s if c % 10 == 0
    end
  end

  def self.limit_images(user, images)
    # 既に配信済みの画像である場合はskip
    images.reject! do |x|
      #puts user.delivered_images.any?{ |d| d.src_url == x.src_url }
      user.delivered_images.any?{ |d| d.src_url == x.src_url }
    end
    puts 'Unique images: ' + images.count.to_s

    # 最大配信数に絞る（推薦度の高い順に残す）
    if images.count > MAX_DELIVER_NUM
      puts 'Removing excessed images...'
      images = images.take MAX_DELIVER_NUM
    end
    puts 'Final delivered images: ' + images.count.to_s
    images
  end

  def self.deliver_from_word(user, target_word)
    # 単純に、title, caption, tagに文字列が含まれているかどうか調べる
    images = Image.joins(:tags).where.not(title: nil, caption: nil, tags: { name: nil })
    puts images.count

    # target_wordに、何らかの文字情報が部分一致するimageがあれば残す
    images = images.map do |image|
      self.contains_word(image, target_word) ? image : nil
    end
    images.compact!
    puts images.count

    images = self.limit_images(user, images)

    self.deliver_images(user, images, target_word)

    puts target_word
    # 最終配信日時を記録
    target_word.last_delivered_at = DateTime.now
  end

  def self.deliver_from_image(user, target_image, count_all, count)
    # Log
    puts 'Processing ' + (count+1).to_s + ' / ' + count_all.to_s
    puts 'User.delivered_images.count: ' + user.delivered_images.count.to_s

    # 推薦イラストを取得
    service = TargetImagesService.new
    result = service.get_preferred_images(target_image)
    images = result[:images]
    puts 'Preferred images: ' + images.count.to_s

    # 既に配信済みの画像である場合はskip
    images.reject! do |x|
      user.delivered_images.any?{ |d| d.src_url == x[:image].src_url }
    end
    puts 'Unique images: ' + images.count.to_s

    # 最大配信数に絞る（推薦度の高い順に残す）
    if images.count > MAX_DELIVER_NUM
      puts 'Removing excessed images...'
      images = images.take MAX_DELIVER_NUM
    end
    puts 'Final delivered images: ' + images.count.to_s

    # User.delivered_imagesへ追加
    c = 0
    images.each do |i|
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
      c += 1
      puts '- Creating delivered_images:' + c.to_s + ' / ' + images.count.to_s if c % 10 == 0
    end

    # 最終配信日時を記録
    target_image.last_delivered_at = DateTime.now
  end

  # @max_size 単位は[MB]
  def self.delete_excessed_records(images, max_size)
    delete_count = 0
    image_size = bytes_to_megabytes(get_total_size(images))

    # 削除する数を計算（順に消してシミュレートしていく）
    images.reorder('created_at ASC').each do |i|
      break if image_size <= max_size
      image_size -= bytes_to_megabytes(i.data.size)
      #puts image_size
      delete_count += 1
    end

    # 古い順(created_atのASC)
    puts 'Deleting excessed images: ' + delete_count.to_s
    images = images.reorder('created_at ASC').limit(delete_count)
    images.destroy_all
    images
  end
end