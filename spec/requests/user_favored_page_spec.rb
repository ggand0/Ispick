require 'spec_helper'

describe "favored_images page" do
  before do
    FactoryGirl.create(:user_with_favored_images, images_count: 1)
    visit root_path
    mock_auth_hash
    click_link 'twitterでログイン'

    # 登録イラスト一覧へのページへ進む
    visit show_favored_images_users_path
    expect(page).to have_content('Clipped Images')
  end

  it "Watch favored_images list" do
    expect(page).to have_css("img[@alt='Madoka']")
  end

  it "Unclip an image" do
    click_link 'Unclip'
    #save_and_open_page
    expect(page.all('.box').count).to eq(0)
  end

  it "Download all images" do
    click_link 'Download zip'
    expect(page.response_headers['Content-Type']).to eq('application/zip')
  end

  it "Go back to user home" do
    click_link 'Back'
    expect(page).to have_content("TODAY's Delivered Images")
  end
end
