#-*- coding: utf-8 -*-
require "#{Rails.root}/app/services/target_images_service"
require "#{Rails.root}/app/helpers/application_helper"
include ApplicationHelper

module Deliver
  # 1ユーザーが持つ1タグあたりの配信イラストの数
  MAX_DELIVER_NUM = 100
  # 配信画像の最大容量[MB]
  MAX_DELIVER_SIZE = 200
  # attachmentが無いレコードに割り当てられる画像url（画像ファイルの有無判定に使用）
  MISSING_URL = '/data/original/missing.png'

  def self.deliver(user_id)
    user = User.find(user_id)

    user.target_words.each do |t|
      Deliver.deliver_from_word(user, t, true) if t.enabled
    end
    user.target_images.each do |t|
      # 14/04/19現在停止させている
      #Deliver.deliver_from_image(user, t) if t.enabled
    end

    # １ユーザーの最大容量を超えていたら古い順に削除
    Deliver.delete_excessed_records(user.delivered_images, MAX_DELIVER_SIZE)
    puts 'Remain delivered_images:' + user.delivered_images.count.to_s
  end

  # @param [Integer] 配信するUserレコードのID
  # @param [Integer] 配信するTagレコードのID
  def self.deliver_keyword(user_id, target_word_id)
    user = User.find(user_id)
    self.deliver_from_word(user, TargetWord.find(target_word_id), false)

    # １ユーザーの最大容量を超えていたら古い順に削除
    Deliver.delete_excessed_records(user.delivered_images, MAX_DELIVER_SIZE)
    puts 'Remain delivered_images:' + user.delivered_images.count.to_s
  end


  # 登録イラストから配信する
  def self.deliver_from_image(user, target_image)
    # 推薦イラストを取得
    service = TargetImagesService.new
    result = service.get_preferred_images(target_image)
    images = result[:images]
    puts 'Preferred images: ' + images.count.to_s

    images = images.map{ |image| image[:image] }    # Hashのarrayではなく単純なImageのarrayにする
    images = self.limit_images(user, images)        # 配信画像を制限する
    self.deliver_images(user, images, target_image) # User.delivered_imagesへ追加
    target_image.last_delivered_at = DateTime.now   # 最終配信日時を記録
  end

  # 登録タグから配信する
  def self.deliver_from_word(user, target_word, is_periodic)
    images = self.get_images(is_periodic)
    puts 'Processing: ' + images.count.to_s

    # 何らかの文字情報がtarget_word.wordと部分一致するimageがあれば残す
    images = images.map do |image|
      self.contains_word(image, target_word) ? image : nil
    end
    images.compact!
    puts 'Matches: ' + images.count.to_s

    images = self.limit_images(user, images)                      # 配信画像を制限する
    self.deliver_images(user, images, target_word, is_periodic)   # User.delivered_imagesへ追加する
    target_word.last_delivered_at = DateTime.now                  # 最終配信日時を記録
  end

  # 文字情報が存在するImageレコードを検索して返す
  # @param [Boolean] 定時配信で呼ばれたのかどうか
  # @return [ActiveRecord_Relation_Image]
  def self.get_images(is_periodic)
    puts Image.count
    if is_periodic
      # 定時配信の場合は、イラスト判定が終了しているもののみ配信
      images = Image.includes(:tags).where.not(title: nil, caption: nil, tags: { name: nil }).
        where.not(is_illust: nil).references(:tags)
    else
      # 即座に配信するときは、イラスト判定を後で行う事が確定しているのでnilのレコードも許容する：
      images = Image.includes(:tags).where.not(
        title: nil, caption: nil, tags: { name: nil }).references(:tags)
    end
    images
  end

  # 特定のImageオブジェクトがtarget_wordにマッチするか判定する
  def self.contains_word(image, target_word)
    word = target_word.person ? target_word.person.name : target_word.word
    image.tags.each do |tag|
      return true if tag.name.include?(word)
    end
    image.title.include?(word) or image.caption.include?(word)
  end

  # @param [Image]
  # @return [DeliveredImage]
  def self.create_delivered_image(image)
    delivered_image = DeliveredImage.new
    image.delivered_images << delivered_image
    delivered_image
  end

  # 各ImageからDelievredImageを生成し、user.delivered_imagesへ追加
  def self.deliver_images(user, images, target, is_periodic)
    images.each_with_index do |image, count|
      # 定期配信する際、dataが何らかの原因で存在しないImageはskip
      next if is_periodic and image.data.url == MISSING_URL

      # DeliveredImageのインスタンス生成
      #delivered_image = self.create_delivered_image(image)
      delivered_image = DeliveredImage.new

      # DB保存後にuser.delivered_imagesに追加して配信する
      if image.delivered_images << delivered_image
        target.delivered_images << delivered_image
        user.delivered_images << delivered_image
        user.save
      end

      puts '- Creating delivered_images:' + count.to_s + ' / ' +
        images.count.to_s if count % 10 == 0
    end
  end

  # 配信画像数を指定枚数に制限する
  # @param [User] 配信対象のUserオブジェクト
  # @param [ActiveRecord_Relation_Image] タグとマッチしたImageのrelation
  # @return [ActiveRecord_Relation_Image] 制限後のrelation
  def self.limit_images(user, images)
    # 既に配信済みの画像を除去
    images.reject! do |x|
      user.delivered_images.any?{ |d| d.image.src_url == x.src_url }
    end

    # 最大配信数に絞る（推薦度の高い順に残す）
    if images.count > MAX_DELIVER_NUM
      puts 'Removing excessed images...'
      images = images.take MAX_DELIVER_NUM
    end

    puts 'Final matched images: ' + images.count.to_s
    images
  end


  # max_size以下になるまでdelivered_imagesのレコードを古い順に消す
  # @param [ActiveRecord::Relation] DeliveredImageを想定
  # @param [Integer] 「ここまで縮めたい」という容量、単位は[MB]
  # @return [ActiveRecord::Relation] 削除後のrelation
  def self.delete_excessed_records(delivered_images, max_size)
    # 画像サイズの合計を取得
    delete_count = 0
    images = delivered_images.map { |var| var.image }
    image_size = bytes_to_megabytes(get_total_size(images))

    # 削除するレコード数を計算（順に容量を足してシミュレートしていく）
    delivered_images.reorder('created_at ASC').each do |i|
      break if image_size <= max_size
      image_size -= bytes_to_megabytes(i.image.data.size)
      delete_count += 1
    end

    # 古い順(created_atのASC)にdelete_count分削除
    puts 'Deleting excessed images: ' + delete_count.to_s
    delivered_images = delivered_images.reorder('created_at ASC').limit(delete_count)
    delivered_images.destroy_all
    delivered_images
  end


  # 全userの配信画像の、元サイトでの統計情報を更新する
  def self.update
    today = Time.now.in_time_zone('Asia/Tokyo').to_date

    User.all.each do |user|
      user.delivered_images.each do |delivered_image|
        image = delivered_image.image

        # DeliveredImageに存在しない場合はnext
        next if DeliveredImage.where(id: delivered_image.id).empty?

        # 当日配信された画像のみ更新する
        next if delivered_image.created_at.in_time_zone('Asia/Tokyo').to_date < today

        # 統計情報を取得出来なかった時もnext
        obj = Object.const_get(image.module_name)
        stats = obj.get_stats(obj.get_client, image.page_url)
        next if not stats

        # favorites値を更新する
        puts "#{image.site_name}: #{image.favorites} -> #{stats[:favorites]}"
        delivered = DeliveredImage.find(delivered_image.id)
        delivered.image.update_attributes(favorites: stats[:favorites])
      end
    end
  end

end