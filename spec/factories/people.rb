# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :person do
    name "鹿目まどか"
    name_type "Character"
  end

  factory :person_madoka, class: Person do
    name '鹿目まどか'
    name_roman 'Kaname Madoka'
    name_english 'Madoka Kaname'
    name_type 'Character'
    name_display '鹿目 まどか（かなめ まどか）'

    after(:create) do |person|
      person.keywords << create(:keyword_title)
      person.keywords << create(:keyword_alias)
    end
  end

  factory :person_madoka_en, class: Person do
    name_roman 'Kaname Madoka'
    name_english 'Madoka Kaname'
    name_type 'Character'
    name_display 'Madoka Kaname'

    after(:create) do |person|
      person.keywords << create(:keyword_title)
      person.keywords << create(:keyword_alias)
    end
  end

  factory :person_miku, class: Person do
    name '初音ミク'
    name_type 'Character'
    name_display '初音 ミク（はつね みく）'
    name_roman 'Hatsune Miku'
    name_english 'Miku Hatsune'
  end
  factory :person_maki, class: Person do
    name '弦巻マキ'
    name_type 'Character'
    name_display '弦巻 マキ（つるまき まき）'
    name_roman 'Tsurumaki Maki'
    name_english 'Maki Tsurumaki'
  end
  factory :person_illya, class: Person do
    name 'イリヤ'
    name_type 'Character'
    name_display 'イリヤスフィール・フォン・アインツベルン'
    name_english 'Illyasviel von Einzbern'
    name_roman 'Illyasviel von Einzbern'
  end
end
