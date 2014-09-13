require 'spec_helper'

describe "favored_images page" do
  before do
    FactoryGirl.create(:twitter_user)
    visit root_path
    mock_auth_hash
    click_link 'Login with twitter'

    # クリップイラスト一覧へのページへ進む
    visit show_favored_images_users_path
    #expect(page).to have_content('Clipped Images')
  end

  it "Watch favored_images list" do
    expect(page).to have_css("img[@alt='Madoka']")
  end

  it "Destroy an image" do
    click_link 'Unclip'
    expect(page.all('.box').count).to eq(0)
  end

  # Debug route
  it "Download all images" do
    click_link 'Download zip'
    expect(page.response_headers['Content-Type']).to eq('application/zip')
  end
end
