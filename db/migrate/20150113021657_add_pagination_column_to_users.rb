class AddPaginationColumnToUsers < ActiveRecord::Migration
  def change
    # Whether it shows images with pagination or infinite scrolling
    add_column :users, :pagination, :boolean, default: false

    # How many images it displays per page or per fetch
    add_column :users, :display_num, :integer, default: 10
  end
end
