class DeliveredImage < ActiveRecord::Base
  belongs_to :user
  belongs_to :image
  belongs_to :targetable, polymorphic: true
  has_many :favored_images
  has_one :feature, as: :featurable

  # 明示的にテーブル名を指定することでエラー回避している
  default_scope { order("#{table_name}.created_at DESC") }
  paginates_per 100

  has_attached_file :data,
    styles: {
      thumb: "300x300#"
    },
    use_timestamp: false
end
