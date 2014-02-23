class Image < ActiveRecord::Base
  has_one :featurable, as: :featurable

	has_attached_file :data,
    :styles => {
      :thumb => "100x100#",
      :small  => "150x150>",
      :medium => "200x200" },
    :use_timestamp => false

  validates_uniqueness_of :src_url

	def image_from_url(url)
		self.data = open(url)
	end
end
