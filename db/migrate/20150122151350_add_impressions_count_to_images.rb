class AddImpressionsCountToImages < ActiveRecord::Migration
  def change
    add_column :images, :impressions_count, :integer, :default => 0, :null => false
  end
end
