# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :target_word do
    word '鹿目 まどか（かなめ まどか）'
    enabled true

    factory :word_with_delivered_images do
      ignore do
        images_count 5
      end
      after(:create) do |target_word, evaluator|
        create_list(:delivered_image_with_targetable, evaluator.images_count, targetable: target_word)
      end
    end
  end

  factory :target_word_not_enabled, class: TargetWord do
    word '美樹 さやか（みき さやか）'
    enabled false
  end
end
