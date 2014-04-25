# Read about factories at https://github.com/thoughtbot/factory_girl
require "#{Rails.root}/spec/support/consts"

FactoryGirl.define do
  factory :delivered_image do
    title "MyText"
    caption "MyText"
    is_illust true
    avoided false
    sequence(:src_url) { |n| "test#{n}@example.com"}
    sequence(:page_url) { |n| Constants::URLS[n % Constants::URLS.count] }
    sequence(:site_name) { |n| Constants::SITE_NAMES[n % Constants::SITE_NAMES.count] }
    sequence(:module_name) { |n| Constants::MODULE_NAMES[n % Constants::MODULE_NAMES.count] }
    association :user, factory: :twitter_user, strategy: :build
    association :targetable, factory: :target_word, strategy: :build
  end

  factory :delivered_image_no_association, class: DeliveredImage do
    sequence(:src_url) { |n| "test#{n}@example.com"}
    sequence(:site_name) { |n| Constants::SITE_NAMES[n % Constants::SITE_NAMES.count] }
    sequence(:module_name) { |n| Constants::MODULE_NAMES[n % Constants::MODULE_NAMES.count ]}
  end

  factory :delivered_image_with_targetable, class: DeliveredImage do
    title "MyText"
    caption "MyText"
    is_illust true
    avoided false
    sequence(:src_url) { |n| "test#{n}@example.com"}
    association :targetable, factory: :target_word, strategy: :build
  end

  factory :delivered_image_photo, class: DeliveredImage do
    title "MyText"
    caption "MyText"
    is_illust false
    avoided false
    sequence(:src_url) { |n| "photo#{n}@example.com"}
  end
  factory :delivered_image_illust, class: DeliveredImage do
    title "MyText"
    caption "MyText"
    is_illust true
    avoided false
    sequence(:src_url) { |n| "illust#{n}@example.com"}
  end

  factory :delivered_image_from_word, class: DeliveredImage do
    title "MyText"
    caption "MyText"
    sequence(:src_url) { |n| "test#{n}@example.com"}
    association :user, factory: :twitter_user, strategy: :build
    association :targetable, factory: :target_word
  end

  factory :delivered_image_from_image, class: DeliveredImage do
    title "MyText"
    caption "MyText"
    sequence(:src_url) { |n| "test#{n}@example.com"}
    association :user, factory: :twitter_user, strategy: :build
    association :targetable, factory: :target_image
  end

  factory :delivered_image_file, class: DeliveredImage do
    title "MyText"
    caption "MyText"
    #avoided false
    favored false
    sequence(:src_url) { |n| "test#{n}@example.com"}
    sequence(:page_url) { |n| Constants::URLS[n % Constants::URLS.count] }
    sequence(:site_name) { |n| Constants::SITE_NAMES[n % Constants::SITE_NAMES.count] }
    data { fixture_file_upload('spec/fixtures/files/madoka.png') }

    # save時にvalidationをスキップする
    to_create do |instance|
      instance.save validate: false
    end

    association :user, factory: :twitter_user, strategy: :build
    association :targetable, factory: :target_word, strategy: :build
  end

  factory :delivered_image_favored, class: DeliveredImage do
    title "MyText"
    caption "MyText"
    sequence(:src_url) { |n| "test#{n}_favored@example.com"}
    favored true
    data { fixture_file_upload('spec/fixtures/files/madoka.png') }
    association :user
  end
  factory :delivered_image_favored_light, class: DeliveredImage do
    title "MyText"
    caption "MyText"
    sequence(:src_url) { |n| "test#{n}_favored@example.com"}
    favored true
  end
  factory :delivered_image_unfavored_light, class: DeliveredImage do
    title "MyText"
    caption "MyText"
    sequence(:src_url) { |n| "test#{n}_favored@example.com"}
    favored false
  end
end
