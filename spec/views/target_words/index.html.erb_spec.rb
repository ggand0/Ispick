require 'spec_helper'

describe "target_words/index" do
  before(:each) do
    assign(:target_words, [
      stub_model(TargetWord,
        :name => "Word"
      ),
      stub_model(TargetWord,
        :name => "Word"
      )
    ])
  end

  it "renders a list of target_words" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Word".to_s, :count => 2
  end
end
