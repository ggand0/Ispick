module Deliver::Words
  # 登録タグから配信する
  # @param [User] 配信するUserレコードのインスタンス
  # @param [TargetWord] 保存済みのTargetWordレコード
  def self.deliver_from_word(user, target_word, is_periodic)
    query = target_word.person ? target_word.person.name : target_word.word
    puts "Starting: target_word=#{query}"

    images = self.get_images(is_periodic, query)
    puts "Processing: #{images.count} images"

    # 何らかの文字情報がtarget_word.wordと部分一致するimageがあれば残す
    images = images.map do |image|
      self.contains_word(image, target_word) ? image : nil
    end
    images.compact!
    puts "Matched: #{images.count} images"

    images = Deliver.limit_images(user, images)                      # 配信画像を制限する
    Deliver.deliver_images(user, images, target_word, is_periodic)   # User.delivered_imagesへ追加する
    target_word.last_delivered_at = DateTime.now                  # 最終配信日時を記録
  end


  # 文字情報が存在するImageレコードを検索して返す
  # @param [Boolean] 定時配信で呼ばれたのかどうか
  # @return [ActiveRecord_Relation_Image]
  def self.get_images(is_periodic, tag)
    if is_periodic
      # 定時配信の場合は、イラスト判定が終了している[is_illustがnilではない]もののみ配信
      images = Image.includes(:tags).
        where.not(is_illust: nil, src_url: nil).where(tags: { name: tag }).
        references(:tags)
    else
      # 即座に配信するときは、イラスト判定を後で行う事が確定しているのでnilのレコードも許容する：
      # が、既存のDL失敗画像で落ちる可能性が高いので要修正
      images = Image.includes(:tags).
        where(tags: { name: tag }).
        references(:tags)
    end
    images
  end

  # 特定のImageオブジェクトがtarget_wordにマッチするか判定する
  # @param [Image] 判定したいImageオブジェクト
  # @param [TargetWord] 比較したいTargetWordオブジェクト
  # @return [Boolean] TargetWordに近いかどうか
  def self.contains_word(image, target_word)
    word = target_word.person ? target_word.person.name : target_word.word
    word_en = target_word.person.name_english if target_word.person and not target_word.person.name_english.empty?

    # まず、タグがマッチするかどうかチェック
    image.tags.each do |tag|
      return true if tag.name.include?(word)
      return true if word_en and tag.name.include?(word_en)
    end

    # タグが含まれていない場合で、title / captionに単語が含まれていればtrue
    return true if image.title and image.title.include?(word) or image.caption and image.caption.include?(word)
    return false if word_en.nil?
    return true if ( !image.title.nil? and image.title.include?(word_en) ) or ( !image.caption.nil? and image.caption.include?(word_en))
    false
  end
end