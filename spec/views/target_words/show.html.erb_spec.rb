require 'spec_helper'

describe "target_words/show" do
  before(:each) do
    @target_word = FactoryGirl.create(:target_word)
    @target_word.person = FactoryGirl.create(:person)
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    expect(rendered).to match(/Word/)
  end
end
