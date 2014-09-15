require 'spec_helper'

describe "user's home page" do
  describe "default features" do
    before do
      FactoryGirl.create(:user_with_target_word_image_file)

      # TODO: デバッグ用のリンクではなく通常のログインフォームからアクセスするようにする
      visit root_path
      mock_auth_hash
      click_link 'Login with twitter'

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
      find(:xpath, "//a/img[@alt='Madoka']/..").click
      #expect(page).to have_content('Detail')
      expect(page).to have_content('Source URL')
    end


  end

  describe "infinite scrolling", :js => true do
    before do
      #Capybara.current_driver = :webkit
      FactoryGirl.create(:user_with_target_word_image_file, images_count: 26)


      visit root_path
      #save_and_open_page
      mock_auth_hash
      click_link 'Login with twitter'
      save_and_open_page

      # /users/homeに移動すること
      uri = URI.parse(current_url)
      expect(uri.to_s).to include(home_users_path)

      visit home_users_path



    end

    after do
      #Capybara.use_default_driver
    end

    it "Watch more images by infinite scrolling" do
      default_per_page = Kaminari.config.default_per_page
      Image.count.should > default_per_page

      page.should have_css('.box', :count => default_per_page)
      puts Capybara.javascript_driver
      puts Capybara.current_driver
      page.execute_script('window.scrollBy(0,100000)')

      page.should have_css('.box', :count => Image.count)
      save_and_open_page
    end
  end

end