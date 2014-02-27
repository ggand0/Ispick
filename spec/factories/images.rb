FactoryGirl.define do
  factory :image do
    title 'madoka'
    sequence(:src_url) { |n| "test#{n}.com" }
  end
end