# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :target_word do
    word '鹿目 まどか（かなめ まどか）'
    enabled true

    after(:build) { |target_word| target_word.class.skip_callback(:create, :after, :search_keyword) }

    factory :word_with_delivered_images do
      ignore do
        images_count 5
      end
      after(:create) do |target_word, evaluator|
        create_list(:delivered_image_with_targetable, evaluator.images_count, targetable: target_word)
      end
      after(:build) { |target_word| target_word.class.skip_callback(:create, :after, :search_keyword) }
    end

    factory :word_with_person do
      ignore do
        words_count 1
      end
      after(:build) do |target_word, evaluator|
        create_list(:person_madoka, evaluator.words_count, target_word: target_word)
      end
      after(:build) { |target_word| target_word.class.skip_callback(:create, :after, :search_keyword) }
    end
  end

  factory :target_word_not_enabled, class: TargetWord do
    word '美樹 さやか（みき さやか）'
    enabled false
  end
end
