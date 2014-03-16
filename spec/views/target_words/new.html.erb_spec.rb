require 'spec_helper'

describe "target_words/new" do
  before(:each) do
    assign(:target_word, stub_model(TargetWord,
      :word => "MyString"
    ).as_new_record)
  end

  it "renders new target_word form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", target_words_path, "post" do
      assert_select "input#target_word_word[name=?]", "target_word[word]"
    end
  end
end
