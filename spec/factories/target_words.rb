# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :target_word do
    sequence(:word) { |n| "鹿目 まどか（かなめ まどか）#{n}" }

    after(:build) { |target_word| target_word.class.skip_callback(:create, :after, :search_keyword) }
    factory :word_with_run_callback do
      after(:create) { |user| user.send(:search_keyword) }
    end

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
  factory :target_word_title, class: TargetWord do
    word '魔法少女まどか☆マギカ'
  end
  factory :target_words, class: TargetWord do
    sequence(:word) { |n| "鹿目 まどか#{n}" }
  end
end
