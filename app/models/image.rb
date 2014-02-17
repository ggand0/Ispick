class Image < ActiveRecord::Base
	has_attached_file :data

	def image_from_url(url)
		self.data = open(url)
	end
end
