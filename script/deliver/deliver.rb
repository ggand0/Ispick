#-*- coding: utf-8 -*-
require 'matrix'
require "#{Rails.root}/app/services/target_images_service"

require "#{Rails.root}/app/helpers/application_helper"
include ApplicationHelper

module Deliver
  require "#{Rails.root}/script/deliver/deliver_images"
  require "#{Rails.root}/script/deliver/deliver_words"


  MAX_DELIVER_NUM = 100                         # 1ユーザーが持つ1タグあたりの配信イラストの数
  MAX_DELIVER_SIZE = 200                        # 配信画像の最大容量[MB]
  MISSING_URL = '/data/original/missing.png'    # attachmentが無いレコードに割り当てられる画像url（画像ファイルの有無判定に使用）


  # 全ての登録タグ/登録画像に対してImagesテーブル内のマッチした画像を配信する
  # @param [Integer] 配信対象のUserオブジェクト
  def self.deliver(user_id)
    user = User.find(user_id)

    user.target_words.each do |t|
      Deliver::Words.deliver_from_word(user, t, true) if t.enabled
    end
    # 登録画像に基づく配信処理：14/06/14現在停止中
    #user.target_images.each do |t|
    #  Deliver::Images.deliver_from_image(user, t) if t.enabled
    #end

    # １ユーザーの最大容量を超えていたら古い順に削除
    Deliver.delete_excessed_records(user.delivered_images, MAX_DELIVER_SIZE)
    puts "Remain delivered_images: #{user.delivered_images.count.to_s}"
  end

  # @param [Integer] 配信するUserレコードのID
  # @param [Integer] 配信するTagレコードのID
  def self.deliver_keyword(user_id, target_word_id)
    user = User.find(user_id)
    target_word = TargetWord.find(target_word_id)
    puts "\nDelivering to target_word=#{target_word_id} start=#{DateTime.now}"

    Deliver::Words.deliver_from_word(user, target_word, false)
  end


  # @param image [Image]
  # @return [DeliveredImage]
  def self.create_delivered_image(image)
    delivered_image = DeliveredImage.new
    image.delivered_images << delivered_image
    delivered_image
  end

  # １つのImageオブジェクトをuserに配信する
  # @param user_id [Integer]
  # @param target [TargetWord/TargetImage]
  # @param image_id [Integer]
  def self.deliver_image(user_id, target, image_id)
    image = Image.find(image_id)
    delivered_image = DeliveredImage.new
    user = User.find(user_id)

    image.delivered_images << delivered_image
    target.delivered_images << delivered_image
    user.delivered_images << delivered_image
  end

  # 各ImageからDelievredImageを生成し、user.delivered_imagesへ追加
  # @param user [User] 配信対象のUserオブジェクト
  # @param images [ActiveRecord::Relation::ActiveRecord_Relation_Image] Imageのリレーション
  # @param target [TargetWord/TargetImage]
  # @param is_periodic [Boolean] 定時配信かどうか
  def self.deliver_images(user, images, target, is_periodic)
    tmp_images = []

    images.each_with_index do |image, count|
      # 定期配信する際、dataが何らかの原因で存在しないImageはskip
      next if is_periodic and image.data.url == MISSING_URL

      # 先の行程でtarget_word/target_imageにマッチはしたが既に配信済みの画像の場合は、
      # target.delivered_imagesにだけ追加
      delivered = false
      user.delivered_images.each do |d|
        if d.image and d.image.src_url == image.src_url
          target.delivered_images << d
          target.delivered_images.uniq!
          delivered = true
          puts "[DEBUG] matched but already delivered: #{image.src_url}"
          break
        end
      end
      next if delivered

      # DeliveredImageのインスタンス生成
      delivered_image = DeliveredImage.new

      # DB保存後にuser.delivered_imagesに追加して配信する
      if image.delivered_images << delivered_image
        target.delivered_images << delivered_image
        #user.delivered_images << delivered_image
        #user.save
        tmp_images << delivered_image
      end

      puts "- Creating delivered_images: #{count.to_s} / #{images.count.to_s}" if count % 10 == 0
    end


    # 投稿日時順（posted_at）に配信される画像群をソートしてから配信する
    tmp_images.each do |image|
      user.delivered_images << image
      user.save
    end
  end

  # 配信画像数を指定枚数に制限する、DL済み前提
  # @param [User] 配信対象のUserオブジェクト
  # @param [ActiveRecord_Relation_Image] タグとマッチしたImageのrelation
  # @return [ActiveRecord_Relation_Image] 制限後のrelation
  def self.limit_images(user, images)
    # 最大配信数に絞る（推薦度の高い順に残す）
    if images.count > MAX_DELIVER_NUM
      puts 'Removing excessed images...'
      images = images.take MAX_DELIVER_NUM
    end

    # posted_atでソートする
    # Homeではcreated_at順にソートするが、
    # １回配信分の中ではposted_at順になる
    #images.sort_by! { |image| image.posted_at }

    puts "Limited: #{images.count.to_s} images"
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
    # Callbacksを呼びたいのでdestroyを使う
    puts "Deleting excessed images: #{delete_count.to_s}"
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