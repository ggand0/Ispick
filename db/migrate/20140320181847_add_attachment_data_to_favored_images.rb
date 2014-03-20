class AddAttachmentDataToFavoredImages < ActiveRecord::Migration
  def self.up
    change_table :favored_images do |t|
      t.attachment :data
    end
  end

  def self.down
    drop_attached_file :favored_images, :data
  end
end
