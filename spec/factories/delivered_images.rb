# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :delivered_image do
    title "MyText"
    caption "MyText"
    src_url "MyText"
  end

  factory :delivered_image_favored, class: DeliveredImage do
    title "MyText"
    caption "MyText"
    sequence(:src_url) { |n| "test#{n}@example.com"}
    favored true
    data { fixture_file_upload('spec/fixtures/files/madoka.png') }
    association :user
  end
end
