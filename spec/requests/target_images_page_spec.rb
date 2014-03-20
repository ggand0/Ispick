require 'spec_helper'

describe "Default feature" do
  describe "target_images page" do
    before do
      FactoryGirl.create(:user_with_target_images, images_count: 1)
      visit root_path
      mock_auth_hash
      click_link 'twitterでログイン'

      # 登録イラスト一覧へのページへ進む
      visit show_target_images_users_path
      expect(page).to have_content('YOUR target_Images')
    end

    it "Watch target images list" do
      expect(page).to have_css("img[@alt='Madoka']")
    end

    it "Create new target_image" do
      click_link 'New Target image'
      expect(page).to have_content('New target_image')

      fill_in 'Title', with: 'This is an integration test'
      attach_file 'Data', "#{Rails.root}/spec/files/target_images/madoka0.jpg"
      click_on 'Create Target image'

      #save_and_open_page
      expect(page).to have_content 'YOUR target_Images'
      expect(page.all('.box').count).to eq(2)
      expect(page.all('.boxInner').count).to eq(2)
    end

    it "Go back to user home" do
      click_link 'Back'
      expect(page).to have_content("TODAY's Delivered Images")
    end
  end
end