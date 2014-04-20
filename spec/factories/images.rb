FactoryGirl.define do
  factory :image do
    title 'test'
    caption 'test'
    sequence(:src_url) { |n| "test#{n}@example.com" }
    sequence(:created_at) { |n| Time.mktime(2014, 1, n, 0, 0, 0) }  # UTCで保存される
    sequence(:page_url) { |n| "test#{n}@example.com/some_page" }
    site_name 'some_site'
    views 10000
    posted_at DateTime.now
    is_illust true

    factory :image_with_tags do
      ignore do
        tags_count 5
      end
      after(:create) do |image, evaluator|
        create_list(:tag, evaluator.tags_count, image: image)
      end
    end

    # save時にvalidationをスキップする
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
        create_list(:tag, evaluator.tags_count, image: image)
      end
    end
    to_create do |instance|
      instance.save validate: false
    end
  end

  factory :image_file, class: Image do
    title 'madoka'
    sequence(:src_url) { |n| "test#{n}.com" }
    data { fixture_file_upload('spec/fixtures/files/madoka.png') }

    # save時にvalidationをスキップする
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
    # save時にvalidationをスキップする
    to_create do |instance|
      instance.save validate: false
    end
  end
end