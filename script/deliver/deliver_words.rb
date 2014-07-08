module Deliver::Words
  # 登録タグから配信する
  # @param [User] 配信するUserレコードのインスタンス
  # @param [TargetWord] 保存済みのTargetWordレコード
  def self.deliver_from_word(user, target_word, logger)
    logger.info "Starting: target_word=#{target_word.inspect}"

    #images = self.get_images(query)
    images = self.get_images(target_word, logger)
    logger.info "Processing: #{images.count} images"

    # 何らかの文字情報がtarget_word.wordと部分一致するimageがあれば残す
    # get_imagesの段階で絞られているので無意味
    #images = images.map do |image|
    #  self.contains_word(image, target_word) ? image : nil
    #end
    images.uniq!
    images.compact!
    logger.info "Matched: #{images.count} images"

    #images = Deliver.limit_images(user, images)                      # 配信画像を制限する
    Deliver.deliver_images(user, images, target_word)                # User.delivered_imagesへ追加する
    target_word.last_delivered_at = DateTime.now                     # 最終配信日時を記録
  end


  # 文字情報が存在するImageレコードを検索して返す
  # @return [ActiveRecord_Relation_Image]
  def self.get_images(target_word, logger)
    query = Scrape.get_query target_word
    title = Scrape.get_titles(target_word).first
    logger.debug "#{title.name}"

    # イラスト判定が終了している[is_illustがnilではない]もののみ配信
    # イラスト判定が終了している=既にダウンロードされている
    # とりあえずは、タイトルタグの画像も一緒に拾ってくる仕様で
    if title.nil? or title.name.nil? or title.name.empty?
      images = Image.includes(:tags).
        where.not(is_illust: nil).where(tags: { name: query }).
        references(:tags)
    else
      # まとめサイト由来の画像のみ広くマッチさせる
      images = Image.includes(:tags).
        where.not(is_illust: nil).
        where(module_name: 'Scrape::Matome')
        where('tags.name=? OR tags.name=?', query, title.name).
        references(:tags)
    end
  end

  # 特定のImageオブジェクトがtarget_wordにマッチするか判定する
  # @param [Image] 判定したいImageオブジェクト
  # @param [TargetWord] 比較したいTargetWordオブジェクト
  # @return [Boolean] TargetWordに近いかどうか
  def self.contains_word(image, target_word)
    word_ja = self.get_query_ja(target_word)
    word_en = self.get_query_en(target_word)
    keywords = self.get_query_keywords(target_word)

    # タグ自身が何らかの文字情報に一致したらmatched
    return true if self.match_word(image, word_ja) or self.match_word(image, word_en)
    # 関連語がヒットしたらmatched
    keywords.each do |word|
      return true if self.match_word(image, word)
    end
    false
  end

  def self.get_query_ja(target_word)
    target_word.person ? target_word.person.name : target_word.word
  end
  def self.get_query_en(target_word)
    target_word.person.name_english if target_word.person and not target_word.person.name_english.empty?
  end
  def self.get_query_keywords(target_word)
    target_word.person ? target_word.person.keywords.map{ |keyword| keyword.word } : []
  end

  def self.match_word(image, word)
    return false if word.nil? or word.empty?

    # まず、タグがマッチするかどうかチェック
    image.tags.each do |tag|
      return true if tag.name.include?(word)
    end

    # タグが含まれていない場合で、title/captionに単語が含まれていればtrue
    return true if (image.title and image.title.include?(word)) or
      (image.caption and image.caption.include?(word))
    false
  end
end