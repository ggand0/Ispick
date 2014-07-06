# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :tag do
    name '鹿目まどか'
  end
  factory :tag_en, class: Tag do
    name 'Madoka Kaname'
  end
  factory :tag_title, class: Tag do
    name '魔法少女まどか☆マギカ'
  end
  factory :tags, class: Tag do
    sequence(:name) { |n| "鹿目まどか#{n}" }
  end
end
