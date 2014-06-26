# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :person do
    name "鹿目まどか"
    name_type "Character"
  end
  factory :person_with_word, class: Person do
    sequence(:name) { |n| "鹿目まどか#{n}" }
    name_english 'Madoka Kaname'
    name_type 'Character'
    name_display '鹿目 まどか（かなめ まどか）'
    association :target_word, factory: :target_word
  end

  factory :person_madoka, class: Person do
    name '鹿目まどか'
    name_english 'Madoka Kaname'
    name_type 'Character'
    name_display '鹿目 まどか（かなめ まどか）'
    association :target_word, factory: :target_word
  end
  factory :person_madoka_en, class: Person do
    name_english 'Madoka Kaname'
    name_type 'Character'
    name_display 'Madoka Kaname'
    association :target_word, factory: :target_word
  end

  factory :person_miku, class: Person do
    name '初音ミク'
    name_type 'Character'
    name_display '初音 ミク（はつね みく）'
  end
  factory :person_maki, class: Person do
    name '弦巻マキ'
    name_type 'Character'
    name_display '弦巻 マキ（つるまき まき）'
  end
  factory :person_illya, class: Person do
    name 'イリヤ'
    name_type 'Character'
    name_display 'イリヤスフィール・フォン・アインツベルン'
  end
end
