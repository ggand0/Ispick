# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :daily_image do
    sequence(:title) { |n| "title#{n}" }
    sequence(:caption) { |n| "caption#{n}" }
  end
end
