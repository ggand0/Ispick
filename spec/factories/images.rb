require "#{Rails.root}/spec/support/consts"

FactoryGirl.define do
  factory :image, class: Image do
    title 'test'
    caption 'test'
    sequence(:src_url) { |n| "test#{n}@example.com" }
    sequence(:created_at) { |n| Time.mktime(2014, 1, n, 0, 0, 0) }  # UTCで保存される
    sequence(:page_url) { |n| "test#{n}@example.com/some_page" }
    sequence(:site_name) { |n| Constants::SITE_NAMES[n % Constants::SITE_NAMES.count] }
    sequence(:module_name) { |n| Constants::MODULE_NAMES[n % Constants::MODULE_NAMES.count] }
    views 10000
    posted_at DateTime.now
    is_illust true

    factory :image_with_tags do
      ignore do
        tags_count 5
      end
      after(:create) do |image, evaluator|
        create_list(:tags, evaluator.tags_count, images: [image])
      end
    end

    # Skip validation when saving
    to_create do |instance|
      instance.save validate: false
    end
  end

  factory :image_for_delivered_image, class: Image do
    title 'test'
    caption 'test'
    sequence(:src_url) { |n| "test#{n}@example.com" }
    sequence(:created_at) { |n| Time.mktime(2014, 1, n, 0, 0, 0) }  # UTCで保存される
    sequence(:page_url) { |n| "test#{n}@example.com/some_page" }
    sequence(:site_name) { |n| Constants::SITE_NAMES[n % Constants::SITE_NAMES.count] }
    sequence(:module_name) { |n| Constants::MODULE_NAMES[n % Constants::MODULE_NAMES.count] }
    views 10000
    posted_at DateTime.now
    is_illust true

    to_create do |instance|
      instance.save validate: false
    end
  end

  factory :image_tag_only, class: Image do
    title 'test'
    caption 'test'
    sequence(:src_url) { |n| "test#{n}@example.com" }

    factory :image_with_only_tags do
      ignore do
        tags_count 5
      end
      after(:create) do |image, evaluator|
        create_list(:tags, evaluator.tags_count, images: [image])
      end
    end
    to_create do |instance|
      instance.save validate: false
    end
  end

  factory :image_file, class: Image do
    title 'madoka'
    caption 'madoka dayo!'
    sequence(:src_url) { |n| "test#{n}@example.com" }
    sequence(:created_at) { |n| Time.mktime(2014, 1, n, 0, 0, 0) }
    sequence(:page_url) { |n| "test#{n}@example.com/some_page" }
    sequence(:site_name) { |n| Constants::SITE_NAMES[n % Constants::SITE_NAMES.count] }
    sequence(:module_name) { |n| Constants::MODULE_NAMES[n % Constants::MODULE_NAMES.count] }
    views 10000
    posted_at DateTime.now
    is_illust true
    data { fixture_file_upload('spec/fixtures/files/madoka.png') }
    to_create do |instance|
      instance.save validate: false
    end
  end
  factory :image_url, class: Image do
    title 'test'
    src_url 'http://lohas.nicoseiga.jp/thumb/3804029i'
  end
  factory :image_min, class: Image do
    src_url 'http://lohas.nicoseiga.jp/thumb/3804029i'
  end

  factory :image_old, class: Image do
    title 'test'
    sequence(:src_url) { |n| "test_old#{n}.com" }
    created_at  Time.utc(2013, 12, 1, 0, 0, 0)
  end

  factory :image_new, class: Image do
    title 'test'
    sequence(:src_url) { |n| "test_new#{n}.com" }
    created_at  Time.utc(2014, 2, 1, 0, 0, 0)
    to_create do |instance|
      instance.save validate: false
    end
  end

  factory :image_photo, class: Image do
    sequence(:src_url) { |n| "test_photo#{n}@example.com" }
    is_illust false

    to_create do |instance|
      instance.save validate: false
    end
  end

  factory :image_tag do
    image_id
    tag_id
  end

  factory :image_nicoseiga, class: Image do
    src_url 'http://lohas.nicoseiga.jp/thumb/3932299i'
    page_url 'http://seiga.nicovideo.jp/seiga/im3932299'
    after(:create) do |image|
      image.tags = [ create(:tag) ]
    end
  end

  factory :image_madoka, class: Image do
    title 'Madoka Kaname'
    caption '"For Madokami so loved the world that She gave us Her Only Self, that whoever believes in Her shall not despair but have everlasting Hope." --Homu 3:16'
    src_url 'http://i.4cdn.org/c/1399620027799.jpg'
    page_url 'http://boards.4chan.org/c/thread/2222110/madoka-kaname'
    # No tags
  end
end