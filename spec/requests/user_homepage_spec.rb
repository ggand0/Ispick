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

      # /users/homeに移動すること
      uri = URI.parse(current_url)
      expect(uri.to_s).to include(home_users_path)
    end

    it "Watch delivered images" do
      visit home_users_path

      # 配信された画像が見える
      expect(page).to have_css('.wrap .box .boxInner')
    end

    it "Watch a delivered image's detail" do
      visit home_users_path

      find(:xpath, "//a/img[@alt='Madoka']/..").click

      expect(page).to have_content('Detail')
    end

=begin
    it "Go to target_images page" do
      visit home_users_path

      click_link '登録イラスト一覧'
      expect(page).to have_content('登録イラスト一覧')
    end
=end

  end
end