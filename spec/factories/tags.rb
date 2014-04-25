# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :tag do
    name '鹿目まどか'
  end
  factory :tags, class: Tag do
    sequence(:name) { |n| "鹿目まどか#{n}" }
  end
end
