require 'spec_helper'
require "#{Rails.root}/app/helpers/delivered_images_helper"

describe "Default feature" do
  describe "User home page" do
    before do
      FactoryGirl.create(:user_with_delivered_images_file, images_count: 1)
      DeliveredImagesHelper.stub(:show_targetable).and_return('madoka')
      visit root_path
      mock_auth_hash
      click_link 'twitterでログイン'
    end

    it "Watch delivered images" do
      visit home_users_path
      #save_and_open_page
      # タイトルが見える
      expect(page).to have_content("TODAY's Delivered Images")

      # 配信された画像が見える
      expect(page).to have_css('.wrap .box .boxInner')
    end

    it "Watch a delivered image's detail" do
      expect(page).to have_content("TODAY's Delivered Images")
      find(:xpath, "//a/img[@alt='Madoka']/..").click
      #save_and_open_page
      expect(page).to have_content('Title')
    end

    it "Go to target_images page" do
      click_link '登録イラスト一覧'
      expect(page).to have_content('YOUR Target Images')
    end

    it "Filter by dates" do
      click_link 'Dates'

      # 今日の日付のメニューitemをクリック
      today = Time.now.in_time_zone('Asia/Tokyo').to_date
      click_link today.strftime("%b %d")
      expect(page).to have_content("TODAY's Delivered Images")
    end

  end
end