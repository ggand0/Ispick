# from http://qiita.com/ysk_1031/items/2ebdfefbca7c01d19ac0
# >文章の配列を引数にとり、それらを形態素解析。
# wikipediaタイトル or はてなキーワードに合致した単語とその出現頻度を計算し、ハッシュで表示するようなロジック。
class KeywordAnalysis
  def self.morphological_analysis(words)
    result = {}
    natto_mecab = Natto::MeCab.new

    words.each do |word|
      natto_mecab.parse(word) do |n|
        next if n.feature.split(",")[-1] !~ /wikipedia|hatena/

        if result["#{n.surface}"]
          result["#{n.surface}"] += 1
        else
          result["#{n.surface}"] = 1
        end
      end
    end

    return result
  end
end