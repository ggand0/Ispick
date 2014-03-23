# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :favored_image do
    title "MyText"
    caption "MyText"
    src_url "MyText"
    user_id 1
  end

  factory :favored_image_file, class: FavoredImage do
    title "MyText"
    caption "MyText"
    src_url "MyText"
    user_id 1
    sequence(:created_at) { |n| Time.mktime(2014, 1, n, 0, 0, 0) }  # UTCで保存される
    data { fixture_file_upload('spec/fixtures/files/madoka.png') }
  end

  factory :favored_image_with_delivered, class: FavoredImage do
    title "MyText"
    caption "MyText"
    src_url "MyText"
    user_id 1
    association :delivered_image, factory: :delivered_image_favored_light
  end
end
