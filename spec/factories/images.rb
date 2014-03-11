FactoryGirl.define do
  factory :image_file, class: Image do
    title 'madoka'
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
end