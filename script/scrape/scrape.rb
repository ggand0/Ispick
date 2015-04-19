#-*- coding: utf-8 -*-
require "#{Rails.root}/app/workers/images_face"

module Scrape
  require "#{Rails.root}/script/scrape/scrape_nico"
  require "#{Rails.root}/script/scrape/scrape_piapro"
  require "#{Rails.root}/script/scrape/scrape_deviant"
  require "#{Rails.root}/script/scrape/scrape_4chan"
  #require "#{Rails.root}/script/scrape/scrape_tumblr"
  #require "#{Rails.root}/script/scrape/scrape_giphy"
  require "#{Rails.root}/script/scrape/scrape_anipic"

  #require "#{Rails.root}/script/scrape/_legacy/scrape_2ch"
  #require "#{Rails.root}/script/scrape/_legacy/scrape_futaba"
  #require "#{Rails.root}/script/scrape/_legacy/scrape_matome"
  #require "#{Rails.root}/script/scrape/_legacy/scrape_tinami"
  require "#{Rails.root}/script/scrape/scrape_pixiv"
  #require "#{Rails.root}/script/scrape/_legacy/scrape_twitter"


  # Scrape images based on all TargetWord records
  def self.scrape_all
    TargetWord.all.each do |target_word|
      self.scrape_keyword target_word
    end
    puts 'DONE!!'
  end

  # Scrape images based on all TargetWord records that are followed by at least a user
  def self.scrape_users
    User.all.each do |user|
      user.target_words.each do |target_word|
        self.scrape_keyword target_word if target_word.enabled
      end
    end
    puts 'DONE!!'
  end

  # For an immediate scraping after following a tag
  # @param [TargetWord] A target TargetWord instance
  def self.scrape_target_word(user_id, target_word, logger)
    Scrape::Nico.new(logger).scrape_target_word(user_id, target_word)
    Scrape::Tumblr.new(logger).scrape_target_word(user_id, target_word)
    #Scrape::Twitter.new(logger).scrape_target_word(user_id, target_word)
    Scrape::Anipic.new(logger).scrape_target_word(user_id, target_word)

    # Search more if an English name exists
    if target_word.person and target_word.person.name_english and not target_word.person.name_english.empty?
      query = target_word.person.name_english
      logger.debug "name_english: #{query}"

      Scrape::Anipic.new(logger).scrape_target_word(user_id, target_word, true)
      Scrape::Tumblr.new(logger).scrape_target_word(user_id, target_word, true)
      Scrape::Giphy.new(logger).scrape_target_word(user_id, target_word)
    end
    logger.info 'scrape_target_word DONE!!'
  end


  # Search for records where Paperclip attachment is nil, and re-download it
  def self.redownload
    images = Image.where(data_file_size: nil)
    puts "number of images with nil data: #{images.count}"

    images.each do |image|
      Resque.enqueue(DownloadImage, image.class.name, image.id, image.src_url)
    end
  end

  # Check if there exists records that have duplicate src_url
  # @param [String] 確認するsource url.
  def self.is_duplicate(src_url)
    Image.where(src_url: src_url).length > 0
  end

  # Get a query string from a TargetWord object used for APIs
  # @return [String] A string used for API requests(like 'Madoka Kaname')
  def self.get_query(target_word)
    return nil if target_word.nil?
    target_word.person ? target_word.person.name : target_word.name
  end

  # Get a query string from a TargetWord object used for APIs
  # @return [String] A string used for API requests(like 'Madoka Kaname')
  def self.get_query_en(target_word, key)
    case key
      when 'english' then
        if target_word.person
          query = target_word.person.name_english  # word:'鹿目まどか', person.name_english:'Madoka Kaname'
        elsif target_word.name.ascii_only?
          query = target_word.name                 # word:'Madoka Kaname', person.name_english:nil
        end
      when 'roman' then
        if target_word.person
          query = target_word.person.name_roman    # word:'鹿目まどか', person.name_roman:'Kaname Madoka'
        elsif target_word.name.ascii_only?
          query = target_word.name                 # word:'Madoka Kaname', person.name_english:nil
        end
      else
        query = Scrape.get_query target_word
      end

    query
  end

  def self.get_result_hash
    { scraped: 0, duplicates: 0, skipped: 0, avg_time: 0, info: 'none' }
  end

  def self.get_result_string(result)
    "scraped: #{result[:scraped]}, duplicates: #{result[:duplicates]}, skipped: #{result[:skipped]}, avg_time: #{result[:avg_time]}, info: #{result[:info]}"
  end

  def self.get_option_hash(validation, large, verbose, resque)
    { validation: validation, large: large, verbose: verbose, resque: resque }
  end

  def self.get_titles (target_word)
    return nil if target_word.nil?
    target_word.person.titles if target_word.person and target_word.person.titles
  end


  # Get a tag. If there's an existing record, return it.
  # @param [String]
  def self.get_tag(tag)
    t = Tag.where(name: tag)

    if t.empty?
      # Detect non-ascii characters, and assume it's Japanese
      ascii = Scrape.is_ascii(tag)
      if ascii
        lang = 'english'
      else
        lang = 'japanese'
      end

      # Create one newly
      t = Tag.new(name: tag, language: lang)
    else
      # There's already a tag record
      t.first
    end
  end

  # Create an array of Tag objects.
  # @param [Array] An array of strings
  # @return [Array] An array of Tag objects
  def self.get_tags(tags)
    tags.map do |tag|
      Scrape.get_tag(tag)
    end
  end

  def self.remove_4bytes(string)
    return nil if string.nil?
    string.each_char.select{ |c| c.bytes.count < 4 }.join('')
  end

  def self.is_ascii(string)
    return nil if string.nil?
    string.match(/\P{ASCII}/) ? false : true
  end

  def self.remove_nonascii(string)
    return nil if string.nil?
    if string.match(/\P{ASCII}/)
      string = string.gsub(/\P{ASCII}/, '').to_s
    end
    string
  end

end
