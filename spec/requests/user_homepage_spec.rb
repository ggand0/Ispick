require 'spec_helper'

describe "Default feature" do
  describe "User home page" do
    before do
      FactoryGirl.create(:user_with_delivered_images, images_count: 1)
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
      expect(page).to have_content('YOUR target_Images')
    end
  end
end