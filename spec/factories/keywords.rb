# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :keyword_title, class: Keyword do
    is_alias false
    name '魔法少女まどか☆マギカ'
  end
  factory :keyword_alias, class: Keyword do
    is_alias false
    name 'かなめ まどか'
  end
end
