require 'spec_helper'

describe "target_words/show" do
  before(:each) do
    @target_word = assign(:target_word, stub_model(TargetWord,
      :word => "Word"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Word/)
  end
end
