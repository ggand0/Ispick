require 'spec_helper'
require 'rake'


describe "util rake tasks" do
  before do
    allow_any_instance_of(IO).to receive(:puts)
    Ispick::Application.load_tasks
  end

  it "delete valid tags" do
    # Create an image that has 'tumblr' as the site_name attribute
    FactoryGirl.create(:image_with_tags)
    puts Image.count
    puts Image.where(site_name: 'tumblr').count
    puts Tag.count
    Image.destroy_all(site_name: 'tumblr')

    Rake::Task['util:delete_tags'].invoke
    expect(Tag.count).to eq(0)
  end


  it "deletes irrelevant images" do
    FactoryGirl.create_list(:image, 10)
    image = Image.first
    image.title = 'r18'
    image.save!

    Rake::Task['util:delete_banned'].invoke
    expect(Image.count).to eq(9)
  end
end
