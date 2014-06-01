require 'spec_helper'

describe "Top page" do
  let(:site_title) { 'Ispick prototype v3' }

  it "display title" do
    visit root_path
    expect(page).to have_css('h1', text: site_title)
  end

  # ログインできること
  it "login with oauth" do
    visit root_path
    mock_auth_hash
    click_link 'twitterでログイン'

    # users/homeに移動しているはず
    uri = URI.parse(current_url)
    expect(uri.to_s).to include(home_users_path)
  end
end
