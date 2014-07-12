class TargetWordsUser < ActiveRecord::Base
  belongs_to :target_word
  belongs_to :user

  validates :target_word_id, uniqueness: { scope: :user_id }
  after_create :search_keyword, unless: :skip_callbacks

  # 少量の画像を抽出・配信する
  def search_keyword
    Resque.enqueue(SearchImages, self.user_id, self.target_word_id)
  end
end
