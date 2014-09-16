# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do

  factory :target_word do
    #sequence(:name) { |n| "鹿目まどか（かなめ まどか）#{n}" }
    sequence(:name) { |n| "鹿目まどか#{n}" }
    after(:build) { |target_word| target_word.class.skip_callback(:create, :after, :search_keyword) }
    #after(:create) do |target_word|
    #  target_word.person = create(:person_madokas)
    #end


    factory :word_with_run_callback do
      after(:create) { |user| user.send(:search_keyword) }
    end


    # images(no file)を持つTargetWordオブジェクト
    # A TargetWord object with images that have no files
    factory :word_with_images do
      ignore do
        images_count 5
      end
      after(:create) do |target_word, evaluator|
        evaluator.images_count.times do
          target_word.images << create(:image)
        end
      end
      after(:build) { |target_word| target_word.class.skip_callback(:create, :after, :search_keyword) }
    end

    # image(with file)を持つTargetWord
    # A TargetWord object with images that have files
    factory :word_with_image_file do
      ignore do
        images_count 1
      end
      after(:create) do |target_word, evaluator|
        evaluator.images_count.times do
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
    name '魔法少女まどか☆マギカ'
  end

  factory :target_words, class: TargetWord do
    sequence(:name) { |n| "鹿目 まどか#{n}" }
    after(:create) do |target_word|
      5.times do
        target_word.images << create(:image)
        target_word.person = create(:person_madokas)
      end
    end
  end

end
