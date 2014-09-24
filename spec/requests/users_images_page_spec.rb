require 'spec_helper'

describe "Default feature" do
  describe "target_images page" do
    let(:page_title) { '登録イラスト一覧' }

    before do
      FactoryGirl.create(:user_with_target_images, images_count: 1)

      # ログインする
      visit root_path
      mock_auth_hash
      click_link 'Continue with Twitter'

      # 登録イラスト一覧へのページへ進む
      visit show_target_images_users_path
      expect(page).to have_content(page_title)
    end

    # 登録した画像を閲覧出来ること
    it "Watch target images list" do
      expect(page).to have_css("img[@alt='Madoka0']")
    end

    # 新たに画像登録出来ること
    it "Create new target_image" do
      click_link 'New Target image'
      expect(page).to have_content('New target_image')

      attach_file 'Data', "#{Rails.root}/spec/files/target_images/madoka0.jpg"
      Resque.stub(:enqueue).and_return nil
      click_on 'Create Target image'

      expect(page).to have_content page_title
      expect(page.all('.box').count).to eq(2)
      expect(page.all('.boxInner').count).to eq(2)
    end

  end
end