FactoryGirl.define do
  factory :image_file, class: Image do
    title 'madoka'
    sequence(:src_url) { |n| "test#{n}.com" }
    data { fixture_file_upload('spec/fixtures/files/madoka.png') }
  end

  factory :image_url, class: Image do
    title 'test'
    src_url 'http://lohas.nicoseiga.jp/thumb/3804029i'
  end

  factory :image do
    title 'test'
    sequence(:src_url) { |n| "test#{n}.com" }
    sequence(:created_at) { |n| Time.mktime(2014, 1, n, 0, 0, 0) }  # UTCで保存される
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
    #data { fixture_file_upload('spec/fixtures/files/madoka.png') }
  end
end