#-*- coding: utf-8 -*-
require "#{Rails.root}/app/services/target_images_service"
require "#{Rails.root}/app/helpers/application_helper"
include ApplicationHelper
require "#{Rails.root}/app/workers/copy_image"

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
      Deliver.deliver_from_word(user, t, true) if t.enabled
    end
    user.target_images.each do |t|
      Deliver.deliver_from_image(user, t, count_all, count) if t.enabled
      count += 1
    end

    # １ユーザーの最大容量を超えていたら古い順に削除
    Deliver.delete_excessed_records(user.delivered_images, MAX_DELIVER_SIZE)
    puts 'Remain delivered_images:' + user.delivered_images.count.to_s
  end

  def self.deliver_keyword(user_id, target_word_id)
    user = User.find(user_id)
    self.deliver_from_word(user, TargetWord.find(target_word_id), false)

    # １ユーザーの最大容量を超えていたら古い順に削除
    Deliver.delete_excessed_records(user.delivered_images, MAX_DELIVER_SIZE)
    puts 'Remain delivered_images:' + user.delivered_images.count.to_s
  end
  def self.deliver_one(user_id, target_word_id, image_id)
    user = User.find(user_id)
    target_word = TargetWord.find(target_word_id)
    image = Image.find(image_id)
    delivered_image = self.create_delivered_image(image)

    if delivered_image.save
      target_word.delivered_images << delivered_image
      user.delivered_images << delivered_image
      user.save
      Resque.enqueue(DownloadImage, delivered_image.class.name,
        delivered_image.id, delivered_image.src_url)
    end

    # １ユーザーの最大容量を超えていたら古い順に削除
    Deliver.delete_excessed_records(user.delivered_images, MAX_DELIVER_SIZE)
    puts 'Remain delivered_images:' + user.delivered_images.count.to_s
  end



  def self.contains_word(image, target_word)
    word = target_word.person ? target_word.person.name : target_word.word
    image.tags.each do |tag|
      return true if tag.name.include?(word)
    end
    image.title.include?(word) or image.caption.include?(word)
  end

  def self.create_delivered_image(image, copy)
    delivered_image = DeliveredImage.create(
      title: image.title,
      caption: image.caption,
      src_url: image.src_url,
      #data: image.data,
      posted_at: image.posted_at,
      views: image.views,
      favorites: image.favorites,
      page_url: image.page_url,
      site_name: image.site_name,
      module_name: image.module_name,
      is_illust: image.is_illust
    )

    delivered_image.data = image.data if copy
    delivered_image
  end

  # User.delivered_imagesへ追加
  def self.deliver_images(user, images, target, copy)
    c = 0
    images.each do |image|
      delivered_image = self.create_delivered_image(image, copy)

      if delivered_image.save
        target.delivered_images << delivered_image
        # file.close出来てもuser.delivered_imagesはclose出来ない
        # (userがglobalから参照される限りuser.delivered_images[i].dataも参照される)ので、
        # ファイルへの参照数がタスク終了するまで増加していくことに注意。
        # 開いているファイル数がulimitで設定されている数を超えると'Too many open files...'エラー
        user.delivered_images << delivered_image# ここがcritical
        user.save

        #Resque.enqueue(CopyImage, delivered_image.id, image.id)
        Resque.enqueue(DownloadImage, delivered_image.class.name,
          delivered_image.id, delivered_image.src_url) if not copy
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
      puts x.src_url
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

  def self.deliver_from_word(user, target_word, copy)
    # 単純に、title, caption, tagに文字列が含まれているかどうか調べる
    # イラスト判定が終わっていないものは飛ばす
    if copy
      images = Image.includes(:tags).where.not(
        title: nil, caption: nil, tags: { name: nil }).where.not(is_illust: nil).references(:tags)
    else
      # 即座に配信するときは、イラスト判定を後で行う事が確定しているので：
      images = Image.includes(:tags).where.not(
        title: nil, caption: nil, tags: { name: nil }).references(:tags)
    end
    puts images.count

    # target_wordに、何らかの文字情報が部分一致するimageがあれば残す
    images = images.map do |image|
      self.contains_word(image, target_word) ? image : nil
    end
    images.compact!
    puts images.count

    # 配信画像を制限する
    images = self.limit_images(user, images)

    # User.delivered_imagesへ追加する
    self.deliver_images(user, images, target_word, copy)

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

    # Hashのarrayではなく単純なImageのarrayにする
    images = images.map{ |image| image[:image] }

    # 配信画像を制限する
    images = self.limit_images(user, images)

    # User.delivered_imagesへ追加
    self.deliver_images(user, images, target_image)

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


  # User.all.delivered_imagesをupdateする
  def self.update()
    User.all.each do |user|
      user.delivered_images.each do |delivered_image|
        stats = Object.const_get(delivered_image.module_name).get_stats(delivered_image.page_url)
        next if not stats
        delivered = DeliveredImage.find(delivered_image.id)

        # favorites値を更新する
        puts "#{delivered_image.site_name}: #{delivered_image.favorites} -> #{stats[:favorites]}"
        delivered.update_attributes(favorites: stats[:favorites])
      end
    end
  end

end