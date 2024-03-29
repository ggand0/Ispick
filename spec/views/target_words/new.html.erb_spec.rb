require 'spec_helper'

describe "target_words/new" do
  before(:each) do
    assign(:target_word, stub_model(TargetWord,
      :name => "MyString"
    ).as_new_record)

    # ransack関連
    FactoryGirl.create(:person)
    @search = Person.search({"name_display_cont"=>"まどか"})
    @people = @search.result(distinct: true).page(params[:page]).per(50)
  end

  it "renders new target_word form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", target_words_path, "post" do
      assert_select "input#target_word_name[name=?]", "target_word[name]"
    end
  end
end
