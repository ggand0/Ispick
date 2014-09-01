class TargetWordsUser < ActiveRecord::Base
  belongs_to :target_word
  belongs_to :user

  validates :target_word_id, uniqueness: { scope: :user_id }
  #after_create :search_keyword, unless: :skip_callbacks

  # Scrape and deliver a small amount of images from each target websites.
  # In older version this function is called right after a TargetWordsUser record is created.
  # Now it's only called when we need to scrape images immediately, like during debugging.
  # 緊急に画像を抽出する必要がある時に呼ぶ（普段は専用のプロセスで間隔を空けながら全TargetWordをクロールしている）。
  # 以前は新しいTargetWordsUserレコードが登録される度に呼んでいた（予め画像をクロールする仕様ではなかった）が、
  # 現在はデバッグ用にしか使っていない。
  def search_keyword
    Resque.enqueue(SearchImages, self.user_id, self.target_word_id)
  end
end
