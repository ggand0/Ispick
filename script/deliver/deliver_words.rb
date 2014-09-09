module Deliver::Words

  # Deliver images based on text tags.
  # 登録タグから配信する
  # @param [User] 配信するUserオブジェクト
  # @param [TargetWord] 保存済みのTargetWordオブジェクト
  def self.deliver_from_word(user, target_word, logger)
    logger.info "Starting: target_word=#{target_word.inspect}"

    # Get images that matche the target_word
    images = self.get_images(target_word, logger)
    logger.info "Matched: #{images.count} images"

    # Remove nil objects
    images.uniq!
    images.compact!

    Deliver.deliver_images(user, images, target_word)                # User.delivered_imagesへ追加する
    target_word.last_delivered_at = DateTime.now                     # 最終配信日時を記録
  end

  # Return an images relation that match to the tag given by teh argument.
  # 文字情報が存在するImageレコードを検索して返す
  # @params target_word [TargetWord] An object of TargetWord class.
  # @params logger [Logger] An instance of Rails Logger class.
  # @return [ActiveRecord_Relation_Image] A relation object that match the target_word.
  def self.get_images(target_word, logger)
    query = Scrape.get_query target_word
    titles = Scrape.get_titles(target_word)
    title = titles.first if (not titles.nil?) and (not titles.empty?)

    # イラスト判定が終了している[is_illustがnilではない]もののみ配信
    # イラスト判定が終了している=既にダウンロードされている
    # 負荷軽減のため当日と前日に抽出された画像に限る
    #（例えば同じタグが付いた画像が1万件あるとwhere文で全てのレコードを含むrelationを作るのにはかなり時間がかかる）。
    if title.nil? or title.name.nil? or title.name.empty?
      images = Image.includes(:tags).
        where.not(data_updated_at: nil).
        where(tags: { name: query }).
        where("images.created_at>?", DateTime.now - 1).
        references(:tags)
    else
      # まとめサイト由来の画像のみ広くマッチさせる
      logger.debug "#{title.name}"
      images = Image.includes(:tags).
        where.not(data_updated_at: nil).
        #where(module_name: 'Scrape::Matome').
        where('tags.name=? OR (tags.name=? AND module_name=? AND  data_content_type=?)', query, title.name, 'Scrape::Matome', 'image/gif').
        references(:tags)
    end
  end

  # Associate all images which is related to a TargetWord record.
  # TargetWord.wordを持つImage全てをそのレコードと関連づける
  def self.associate_words_with_images
    TargetWord.all.each do |target_word|
      # target_word.nameと同名のタグを持つimagesを取得
      query = Scrape.get_query target_word
      images = Image.includes(:tags).
        where.not(data_updated_at: nil).                        # ダウンロード済みでない者を除外する
        where(tags: { name: query }).
        references(:tags)

      if images.count != target_word.images.count
        target_word.images.clear
        target_word.images = images
        puts "Associated #{images.count} images to target_word: #{target_word.name}"
      end

      puts "Skiped target_word: #{target_word.name}"
    end
  end

  def self.associate_words_with_images!
    TargetWord.all.each do |target_word|
      query = Scrape.get_query target_word
      images = Image.includes(:tags).
        where.not(data_updated_at: nil).
        where(tags: { name: query }).
        references(:tags)

      target_word.images.clear
      target_word.images = images
      puts "Associated #{images.count} images to target_word: #{target_word.name}"
    end
  end



  # =================
  #  Unused methods
  # =================
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
    target_word.person ? target_word.person.name : target_word.name
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