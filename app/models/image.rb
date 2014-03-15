class Image < ActiveRecord::Base
  has_one :feature, as: :featurable

  # 明示的にテーブル名を指定することでエラー回避
  default_scope { order("#{table_name}.created_at DESC") }
  paginates_per 100

	has_attached_file :data,
    styles: {
      thumb: "100x100#",
      small: "150x150>",
      medium: "200x200" },
    use_timestamp: false

  validates_uniqueness_of :src_url

	def image_from_url(url)
    self.data = URI.parse(url)
	end
end
