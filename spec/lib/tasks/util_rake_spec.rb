require 'spec_helper'

=begin

describe "util:delete_banned" do
  before do
    IO.any_instance.stub(:puts)
  end
  include_context 'rake'
  its(:prerequisites) { should include('environment') }

  it "deletes irrelevant images" do
    FactoryGirl.create_list(:image, 10)
    image = Image.first
    image.title = 'r18'
    image.save!

    subject.invoke
    Image.count.should eq(9)
  end
end
=end