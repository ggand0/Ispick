# encoding: utf-8
require 'open-uri'
require 'builder'

class AniDB
  attr_accessor :xml, :output, :titles, :hash
  # 10000件のアニメ情報があるinput用xml
  file_path = "#{Rails.root}/script/anidb/anime-titles.xml"

  # 出力用のXML::Documentオブジェクトを読み込むファイル。
  # Nokogiri::XML::Elementを追加して新しいxmlを作成する。
  output_path = "#{Rails.root}/script/anidb/anime_titles_template.xml"

  # 実際に出力するファイルのpath
  test_path = "#{Rails.root}/script/anidb/anime_titles_2014.xml"
  hash_path = "#{Rails.root}/script/anidb/anidb_match_status"

  def initialize()
    @xml = Nokogiri::XML(open file_path)
    @output = Nokogiri::XML(open output_path)
    @titles = Title.all
    @hash = {}
    @titles.each do |title|
      @hash[title.name_english] = false
    end
  end

  def search_attribute(attributes, target)
    matched = false

    attributes.each do |attribute|
      if not attribute.nil? and (attribute.content.downcase.include? target.downcase or
        target.downcase.include? attribute.content.downcase)

        @output.root.add_child anime
        puts "Added an en element: #{anime_en.content}"
        @hash[title.name_english] = true
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
      x-jats = anime.xpath('title[@xml:lang="x-jat"]')
      x-unks = anime.xpath('title[@xml:lang="x-unk"]')
      next if anime_ens.nil? and x-jats.nil? and x-unks.nil?

      @titles.each do |title|
        matched = search_attribute(anime_ens, title.name_english)
        break if matched

        unless title.name.nil? or title.name.empty?
          matched = search_attribute(anime_jas, title.name)
          break if matched
        end

        matched = search_attribute(x-jats, title.name_english)
        break if matched

        matched = search_attribute(x-unks, title.name_english)
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
    File.open(test_path, 'w') { |f| f.print(output.to_xml) }
    File.open(hash_path, 'w') do |f|
      @hash.each do |key, value|
        f.write("#{key}: #{value}\n")
      end
    end
  end

end


anidb = AniDB.new
anidb.main