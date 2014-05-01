class DeliveredImage < ActiveRecord::Base
  belongs_to :user
  belongs_to :favored_image
  belongs_to :targetable, polymorphic: true
  has_one :feature, as: :featurable
  has_one :image

  # 明示的にテーブル名を指定することでエラー回避している
  default_scope { order("#{table_name}.created_at DESC") }
  paginates_per 100

  has_attached_file :data,
    styles: {
      thumb: "300x300#"
    },
    use_timestamp: false

  # Imageモデルで一度validateされているはずだが、一応定義
  #validates_uniqueness_of :src_url

  # 後でmodule化する
  def image_from_url(url)
    require 'open-uri'
    self.data = open(url)
  end
end
