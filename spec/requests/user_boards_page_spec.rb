require 'spec_helper'


describe "Boards page" do
  before do
    @user = FactoryGirl.create(:twitter_user)
    visit root_path
    mock_auth_hash
    click_link 'Continue with Twitter'
    visit boards_users_path
    #save_and_open_page
  end

  describe "default features" do
    it "watches favored_images list of the default image_board" do
      expect(page).to have_css("img[@alt='Madoka0']")
    end
  end


  describe "boards editing features", :js => true do
    it "unclips the image of the default board" do
      page.find('.block').hover
      expect(page).to have_content('Unclip')
      click_link 'Unclip'
      expect(page.all('.block').count).to eq(0)
    end

    it "renames the default image_board" do

    end

    it "selects another image_board" do
      first('.glyphicon-list').click
      click_link 'A board without images'
      expect(page).not_to have_content('MyText')
    end

    it "deletes an optional image_board" do
      first('.glyphicon-list').click
      click_link 'A board without images'
      first('.glyphicon-remove').click
      page.driver.browser.accept_js_confirms
      expect(@user.image_boards.count).to eq(1)
    end

    # Note: This action is for debugging
    it "downloads images of the default board" do
      #click_link 'Download zip'
      #expect(page.response_headers['Content-Type']).to eq('application/zip')
    end
  end

end
