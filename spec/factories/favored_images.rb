# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :favored_image do
    title "MyText"
    caption "MyText"
    src_url "MyText"
  end

  # favored_images with actual image files
  factory :favored_image_file, class: FavoredImage do
    title "MyText"
    caption "MyText"
    src_url "MyText"

    # Note that this value is UTC
    sequence(:created_at) { |n| Time.mktime(2014, 1, n, 0, 0, 0) }
    data { fixture_file_upload('spec/files/test_images/madoka0.jpg') }

    # Skip validation when saving
    to_create do |instance|
      instance.save validate: false
    end
  end


  factory :favored_image_with_image, class: FavoredImage do
    title "MyText"
    caption "MyText"
    src_url "MyText"

    association :image, factory: :image
  end
end
