class AddAttachmentDataToTargetImages < ActiveRecord::Migration
  def self.up
    change_table :target_images do |t|
      t.attachment :data
    end
  end

  def self.down
    drop_attached_file :target_images, :data
  end
end
