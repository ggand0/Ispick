# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do

  factory :target_word do
    sequence(:word) { |n| "鹿目 まどか（かなめ まどか）#{n}" }
    after(:build) { |target_word| target_word.class.skip_callback(:create, :after, :search_keyword) }
    factory :word_with_run_callback do
      after(:create) { |user| user.send(:search_keyword) }
    end


    # images(no file)を持つTargetWordオブジェクト
    factory :word_with_images do
      after(:create) do |target_word, evaluator|
        5.times do
          target_word.images << create(:image)
        end
      end
      after(:build) { |target_word| target_word.class.skip_callback(:create, :after, :search_keyword) }
    end

    # an image(no file)を持つTargetWord
    factory :word_with_image do
      after(:create) do |target_word|
        1.times do
          target_word.images << create(:image_file)
        end
      end
    end

    # an image(with file)を持つTargetWord
    factory :word_with_image_file do
      after(:create) do |target_word|
        1.times do
          target_word.images << create(:image_file)
        end
      end
    end

    factory :word_with_image_dif_time do
      after(:create) do |target_word|
        1.times do
          target_word.images << create(:image_dif_time)
        end
      end
    end
    factory :word_with_image_photo do
      after(:create) do |target_word|
        1.times do
          target_word.images << create(:image_photo)
        end
      end
    end


    # A TagetWord object which is associated with a Person record
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


  # A TagetWord object which is associated with a Title record
  factory :target_word_title, class: TargetWord do
    word '魔法少女まどか☆マギカ'
  end

  factory :target_words, class: TargetWord do
    sequence(:word) { |n| "鹿目 まどか#{n}" }
    after(:create) do |target_word|
      5.times do
        target_word.images << create(:image)
      end
    end
  end

end
