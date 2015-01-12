require 'spec_helper'

# Integration specs of target_images related pages.
# Note that this pages are not in use for now[14/09/25].
describe "Default feature" do
  describe "target_images page" do
    let(:page_title) { 'Your target images' }

    before do
      FactoryGirl.create(:user_with_target_images, images_count: 1)

      # Log in
      visit root_path
      mock_auth_hash
      click_link 'Continue with Twitter'

      # Preceed to target_images index page
      visit show_target_images_users_path
      expect(page).to have_content(page_title)
    end

    it "Watch target images list" do
      expect(page).to have_css("img[@alt='Madoka0']")
    end

    it "Create new target_image" do
      click_link 'New Target image'
      expect(page).to have_content('New target_image')

      attach_file 'Data', "#{Rails.root}/spec/files/target_images/madoka0.jpg"
      allow(Resque).to receive(:enqueue).and_return nil
      click_on 'Create Target image'

      expect(page).to have_content page_title
      expect(page.all('.box').count).to eq(2)
      expect(page.all('.boxInner').count).to eq(2)
    end

  end
end