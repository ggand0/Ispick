class CreateTargetSitesUsers < ActiveRecord::Migration
  def change
    create_table :target_sites_users do |t|
      t.integer :target_site_id, null: false
      t.integer :user_id, null: false
    end

    # Seed static records
    Image::TARGET_SITES_DISPLAY.each do |site|
      TargetSite.create!(name: site)
      puts "Seeding #{site} ..."
    end
  end
end
