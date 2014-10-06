require 'spec_helper'

describe "Top page" do
  let(:site_title) { 'Ispick Beta' }

  it "display title" do
    visit root_path
    expect(page).to have_css('h1', text: site_title)
  end

  # Being able to log in the site
  it "login with oauth" do
    visit root_path
    mock_auth_hash
    click_link 'Continue with Twitter'

    # the user should have moved to users/home
    uri = URI.parse(current_url)
    expect(uri.to_s).to include(home_users_path)
  end
end
