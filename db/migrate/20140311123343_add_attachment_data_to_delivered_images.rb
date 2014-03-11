class AddAttachmentDataToDeliveredImages < ActiveRecord::Migration
  def self.up
    change_table :delivered_images do |t|
      t.attachment :data
    end
  end

  def self.down
    drop_attached_file :delivered_images, :data
  end
end
