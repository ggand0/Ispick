# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :person do
    name "MyString"
    name_type ""
  end

  factory :person_madoka, class: Person do
    name '鹿目まどか'
    name_type 'Character'
    name_display '鹿目 まどか（かなめ まどか）'
  end
end
