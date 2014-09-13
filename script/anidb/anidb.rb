# encoding: utf-8
require 'open-uri'
require 'builder'


class AniDB
  attr_accessor :xml, :output, :titles, :hash

  # 10000件のアニメ情報があるinput用xml
  FILE_PATH = "#{Rails.root}/script/anidb/anime-titles.xml"

  # 出力用のXML::Documentオブジェクトを読み込むファイル。
  # Nokogiri::XML::Elementを追加して新しいxmlを作成する。
  OUTPUT_PATH = "#{Rails.root}/script/anidb/anime_titles_template.xml"

  # 実際に出力するファイルのpath
  TEST_PATH = "#{Rails.root}/script/anidb/anime_titles_2014.xml"
  HASH_PATH = "#{Rails.root}/script/anidb/anidb_match_status"

  def initialize()
    @xml = Nokogiri::XML(open FILE_PATH)
    @output = Nokogiri::XML(open OUTPUT_PATH)
    @titles = Title.all
    @hash = {}
    @titles.each do |title|
      @hash[title.name_english] = false
    end
  end

  def search_attribute(attributes, target, anime, key)
    matched = false

    attributes.each do |attribute|
      if not attribute.nil? and (attribute.content.downcase.include? target.downcase or
        target.downcase.include? attribute.content.downcase)

        @output.root.add_child anime
        puts "Added an en element: #{attribute.content}"
        @hash[key] = true
        matched = true
        break
      end
    end
    matched
  end

  def main
    @xml.search('anime').each_with_index do |anime, count|
      anime_ens = anime.xpath('title[@xml:lang="en"]')
      anime_jas = anime.xpath('title[@xml:lang="ja"]')
      x_jats = anime.xpath('title[@xml:lang="x-jat"]')
      x_unks = anime.xpath('title[@xml:lang="x-unk"]')
      next if anime_ens.nil? and x_jats.nil? and x_unks.nil?

      @titles.each do |title|
        matched = search_attribute(anime_ens, title.name_english, anime, title.name_english)
        break if matched

        unless title.name.nil? or title.name.empty?
          matched = search_attribute(anime_jas, title.name, anime, title.name_english)
          break if matched
        end

        matched = search_attribute(x_jats, title.name_english, anime, title.name_english)
        break if matched

        matched = search_attribute(x_unks, title.name_english, anime, title.name_english)
        break if matched
      end # titles.each

      puts "count: #{count}" if count % 1000 == 0
    end

    print()
    output()
  end

  def print
    matched_count = 0
    unmatched_count = 0
    @hash.map { |k,v| unmatched_count +=1 if !v }
    @hash.map { |k,v| matched_count +=1 if v }
    puts "unmatched titles: #{unmatched_count}"
    puts "matched titles: #{matched_count}"
  end

  def output
    @hash = hash.map { |k,v| k if !v }
    @hash.compact!
    puts "Unmatched titles:"
    @hash.each { |k,v| puts "#{k}\n" }
    File.open(TEST_PATH, 'w') { |f| f.print(@output.to_xml) }
    File.open(HASH_PATH, 'w') do |f|
      @hash.each do |key, value|
        f.write("#{key}: #{value}\n")
      end
    end
  end

end


anidb = AniDB.new
anidb.main