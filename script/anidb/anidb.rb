# encoding: utf-8
require 'open-uri'
require 'builder'

# 10000件のアニメ情報があるinput用xml
file_path = "#{Rails.root}/script/anidb/anime-titles.xml"

# 出力用のXML::Documentオブジェクトを読み込むファイル。
# Nokogiri::XML::Elementを追加して新しいxmlを作成する。
output_path = "#{Rails.root}/script/anidb/anime_titles_template.xml"

# 実際に出力するファイルのpath
test_path = "#{Rails.root}/script/anidb/anime_titles_2014.xml"
hash_path = "#{Rails.root}/script/anidb/anidb_match_status"


xml = Nokogiri::XML(open file_path)
output = Nokogiri::XML(open output_path)
titles = Title.all
match_count = 0
hash = {}
titles.each do |title|
  hash[title.name_english] = false
end

xml.search('anime').each_with_index do |anime, count|
  anime_ens = anime.xpath('title[@xml:lang="en"]')
  anime_jas = anime.xpath('title[@xml:lang="ja"]')
  anime_mains = anime.xpath('title[@xml:lang="x-jat"]')
  anime_officials = anime.xpath('title[@xml:lang="x-unk"]')
  next if anime_ens.nil? and anime_mains.nil? and anime_officials.nil?

  matched = false
  titles.each do |title|
    anime_ens.each do |anime_en|
      if not anime_en.nil? and (anime_en.content.downcase.include? title.name_english.downcase or
        title.name_english.downcase.include? anime_en.content.downcase)
        output.root.add_child anime
        puts "Added an en element: #{anime_en.content}"
        match_count += 1
        hash[title.name_english] = true
        matched = true
        break
      end
    end
    break if matched

=begin
=end
    unless title.name.nil? or title.name.empty?
      anime_jas.each do |anime_ja|
        if not anime_ja.nil? and (anime_ja.content.downcase.include? title.name.downcase or
          title.name.downcase.include? anime_ja.content.downcase)
          output.root.add_child anime

          puts "Added an ja element: #{anime_ja.content}"
          puts "DEBUG: #{title.name}"

          match_count += 1
          hash[title.name_english] = true
          matched = true
          break
        end
      end
      break if matched
    end


    anime_mains.each do |anime_main|
      if not anime_main.nil? and (anime_main.content.downcase.include? title.name_english.downcase or
        title.name_english.downcase.include? anime_main.content.downcase)
        output.root.add_child anime
        puts "Added an main element: #{anime_main.content}"
        hash[title.name_english] = true
        match_count += 1
        matched = true
        break
      end
    end
    break if matched

    anime_officials.each do |anime_official|
      if not anime_official.nil? and (anime_official.content.downcase.include? title.name_english.downcase or
        title.name_english.downcase.include? anime_official.content.downcase)
        output.root.add_child anime
        hash[title.name_english] = true
        puts "Added an official element: #{anime_official.content}"
        match_count += 1
        matched = true
        break
      end
    end
    break if matched

  end # titles.each

  puts "count: #{count}" if count % 1000 == 0
end

matched_count = 0
unmatched_count = 0
hash.map { |k,v| unmatched_count +=1 if !v }
hash.map { |k,v| matched_count +=1 if v }
puts "unmatched titles: #{unmatched_count}"
puts "matched titles: #{matched_count}"

hash = hash.map { |k,v| k if !v }
hash.compact!
puts "Unmatched titles:"
hash.each { |k,v| puts "#{k}\n" }
File.open(test_path, 'w') { |f| f.print(output.to_xml) }
File.open(hash_path, 'w') do |f|
  hash.each do |key, value|
    f.write("#{key}: #{value}\n")
  end
end
