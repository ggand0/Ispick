require 'spec_helper'

describe "Preferences page", :js => true do
  before do
    @user = FactoryGirl.create(:twitter_user)
    @tag = '鹿目まどか1'#'Madoka Kaname1'
    FactoryGirl.create(:user_with_tags)
    visit root_path
    mock_auth_hash
    click_link 'Continue with Twitter'
    visit preferences_users_path

    #save_and_open_page
  end

  it "sees popular tags" do
    expect(page).to have_content(@tag)
  end

  it "adds one of popular tags to the tags" do
    all(:css, 'span.glyphicon-plus').first.click
    wait_for_ajax
    expect(@user.tags.count).to eq(1)
  end

  it "sees the related images of a tag by clicking its button" do
    click_link @tag
    wait_for_ajax

    expect(page).to have_xpath("//a/img[@alt='Madoka0']/..")
  end

  it "removes a followed tag" do
    all(:css, 'span.glyphicon-plus').first.click
    wait_for_ajax

    # Click 'X' button
    within '.followed-tags' do
      find("a[data-method='delete']").click
    end
    wait_for_ajax
    expect(@user.tags.count).to eq(0)
  end

  it "searches a tag with a keyword" do
  end
end
