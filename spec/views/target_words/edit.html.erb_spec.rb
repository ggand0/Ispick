require 'spec_helper'

describe "target_words/edit" do
  before(:each) do
    @target_word = assign(:target_word, stub_model(TargetWord,
      :name => "MyString"
    ))
  end

  it "renders the edit target_word form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", target_word_path(@target_word), "post" do
      assert_select "input#target_word_name[name=?]", "target_word[name]"
    end
  end
end
