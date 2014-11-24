require 'spec_helper'

describe "user's home page" do
  describe "default features" do
    before do
      FactoryGirl.create(:user_with_tag_images_file)
      visit root_path
      mock_auth_hash
      click_link 'Continue with Twitter'
      #save_and_open_page
    end

    # URIが正しい
    it "moves to /users/home" do
      uri = URI.parse(current_url)
      expect(uri.to_s).to include(home_users_path)
    end

    # 配信された画像のサムネを見る事が出来る
    it "displays crawled images" do
      visit home_users_path
      #save_and_open_page
      expect(page).to have_css('.wrapper .block .titleBox')
    end

    # クリックすると画像の詳細情報を閲覧出来る
    it "displays an image's details by clicking the picture" do
      visit home_users_path
      find(:xpath, "//a/img[@alt='Madoka0']/..").click
      expect(page).to have_content('madoka')            # sees the title
      expect(page).to have_content('madoka dayo!')      # sees the caption
    end

    it "can sign out" do

    end
  end


  describe "clipping images", :js => true do
    before do
      user = FactoryGirl.create(:user_with_tag_images_file, images_count: 1)
      @board = user.image_boards.first
      visit root_path
      mock_auth_hash
      click_link 'Continue with Twitter'
      visit home_users_path
    end

    it "changes the avatar image to another one" do

    end

    # 'Clip'ボタンをクリックし、ボード名のボタンをさらにクリックする事で
    # お気に入り画像をそのボードに登録出来る
    it "clips an image by clicking the 'Clip' button" do
      page.find('.block').hover
      expect(page).to have_css('span.glyphicon-paperclip')
      find('.glyphicon-paperclip').click
      wait_for_ajax
      windows.length.should == 1

      within_window(windows.last) do
        form = page.find(:xpath, "//input[@value='New board']")
        expect(form).to_not eq(nil)
        expect(page).to have_content('Choose a board')

        click_button 'Clip this'
        wait_for_ajax
      end

      # default one + clipped one = 2 favored_images
      expect(@board.favored_images.count).to eq(2)
    end
  end


  describe "infinite scrolling", :js => true do
    before do
      FactoryGirl.create(:user_with_tag_images_file, images_count: 26)
      visit root_path
      mock_auth_hash
      click_link 'Continue with Twitter'
      visit home_users_path
    end

    # 無限スクロール機能によってより多くの画像を１画面で見る事が出来る
    it "watches more images by infinite scrolling" do
      default_per_page = Kaminari.config.default_per_page
      puts default_per_page
      Image.count.should > default_per_page

      page.should have_css('.block', :count => default_per_page)
=begin
      page.execute_script('window.scrollBy(0,100000)')
      wait_for_ajax
      page.execute_script('window.scrollBy(0,100000)')
      wait_for_ajax
      page.should have_css('.block', :count => Image.count)
=end
    end
  end

end