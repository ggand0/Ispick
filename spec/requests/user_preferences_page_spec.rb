require 'spec_helper'

describe "Preferences page", :js => true do
  before do
    @user = FactoryGirl.create(:twitter_user)
    FactoryGirl.create(:user_with_target_words)
    visit root_path
    mock_auth_hash
    click_link 'Continue with Twitter'
    visit preferences_users_path
    #save_and_open_page
    @tag = 'Madoka Kaname1'#'鹿目まどか1'
  end

  it "sees popular tags" do
    expect(page).to have_content(@tag)
  end

  it "adds one of popular tags to the target_words" do
    click_link @tag
    wait_for_ajax
    expect(@user.target_words.count).to eq(1)
  end

  it "sees the related images of a tag by clicking its button" do
    click_link @tag
    wait_for_ajax

    within '.followed-tags' do
      find('a', text: @tag).click
    end

    # TODO: Seed a target_word with images
    expect(page).to have_content('Found 0 images.')
  end

  it "removes a followed tag" do
    click_link @tag
    wait_for_ajax

    # Click 'X' button
    within '.followed-tags' do
      find("a[data-method='delete']").click
    end
    wait_for_ajax
    expect(@user.target_words.count).to eq(0)
  end

  it "searches a tag with a keyword" do

  end
end
