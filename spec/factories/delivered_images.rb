# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :delivered_image do
    title "MyText"
    caption "MyText"
    sequence(:src_url) { |n| "test#{n}@example.com"}
    association :user, factory: :twitter_user, strategy: :build
  end

  factory :delivered_image_file, class: DeliveredImage do
    title "MyText"
    caption "MyText"
    #avoided false
    favored false
    sequence(:src_url) { |n| "test#{n}@example.com"}
    data { fixture_file_upload('spec/fixtures/files/madoka.png') }

    association :user, factory: :twitter_user, strategy: :build
  end

  factory :delivered_image_favored, class: DeliveredImage do
    title "MyText"
    caption "MyText"
    sequence(:src_url) { |n| "test#{n}@example.com"}
    favored true
    data { fixture_file_upload('spec/fixtures/files/madoka.png') }
    association :user
  end
  factory :delivered_image_favored_light, class: DeliveredImage do
    title "MyText"
    caption "MyText"
    sequence(:src_url) { |n| "test#{n}@example.com"}
    favored true
  end
  factory :delivered_image_unfavored_light, class: DeliveredImage do
    title "MyText"
    caption "MyText"
    sequence(:src_url) { |n| "test#{n}@example.com"}
    favored false
  end
end
