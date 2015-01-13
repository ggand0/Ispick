class ChangeConvnetFeatureFormatInFeature < ActiveRecord::Migration
	def up
    # Set LONGTEXT type on MySQL
	  change_column :features, :convnet_feature, :text, :limit => 4294967295
	end
	def down
	  change_column :features, :convnet_feature, :text
	end
end
