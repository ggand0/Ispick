require 'open-uri'
require 'builder'

file_path = "#{Rails.root}/script/anime_titles.xml"           # 10000件のアニメ情報があるinput用xml

# 出力用のXML::Documentオブジェクトを手っ取り早く作るために読み込むファイル。
# Nokogiri::XML::Elementを追加して新しいxmlを作成する
output_path = "#{Rails.root}/script/anime_titles_output.xml"

# 実際に出力するファイルのpath
test_path = "#{Rails.root}/script/anime_titles_test.xml"
xml = Nokogiri::XML(open file_path)
output = Nokogiri::XML(open output_path)

# Builderを使うのは止めた
#output = Builder::XmlMarkup.new( :indent => 2 )
#output.instruct! :xml, :encoding => "ASCII"
#output.product do |p|
#  p.name "Test"
#end

xml.search('anime').each do |anime|
  Title.all.each do |title|
    if anime.xpath('title[@xml:lang="en"]') == title.name
      output.root.add_child anime
    end
  end
end

File.open(test_path, 'w') { |f| f.print(output.to_xml) }
