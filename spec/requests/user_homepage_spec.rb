require 'spec_helper'
require "#{Rails.root}/app/helpers/delivered_images_helper"

describe "Default feature" do
  describe "User home page" do
    before do
      #FactoryGirl.create(:user_with_delivered_images_file, images_count: 1)
      #FactoryGirl.create(:user_with_target_words)
      FactoryGirl.create(:user_with_target_word_image_file)
      #DeliveredImagesHelper.stub(:show_targetable).and_return('madoka')
      visit root_path
      mock_auth_hash
      click_link 'twitterでログイン'

      # /users/homeに移動すること
      uri = URI.parse(current_url)
      expect(uri.to_s).to include(home_users_path)
    end


    # 配信された画像のサムネが見えるはず
    it "Watch delivered images" do
      visit home_users_path
      expect(page).to have_css('.wrap .box .boxInner')
    end

    # クリックすれば詳細も見れるはず
    it "Watch a delivered image's detail" do
      visit home_users_path
      #save_and_open_page
      find(:xpath, "//a/img[@alt='Madoka']/..").click
      #save_and_open_page
      #expect(page).to have_content('Detail')
      expect(page).to have_content('Source URL')
    end
  end

end