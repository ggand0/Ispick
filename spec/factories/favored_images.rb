# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :favored_image do
    title "MyText"
    caption "MyText"
    src_url "MyText"
    user_id 1
  end

  factory :favored_image_with_delivered, class: FavoredImage do
    title "MyText"
    caption "MyText"
    src_url "MyText"
    user_id 1
    association :delivered_image, factory: :delivered_image_favored_light
  end
end
