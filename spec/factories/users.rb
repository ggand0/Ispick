# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "test_user#{n}@example.com" }
    sequence(:password) { |n| "#{n}2345678" }
    sequence(:name) { |n| "ispick#{n}" }

    # デフォルトでユーザーが持つFavoredImage
    after(:create) do |user|
      1.times { create(:favored_image_file, image_board: user.image_boards.first) }
    end
  end

  factory :twitter_user, class: User do
    sequence(:email) { |n| "test#{n}@example.com" }
    password '12345678'
    provider  'twitter'
    uid '12345678'
    sequence(:name) { |n| "ispick_twitter#{n}" }

    factory :user_with_delivered_images do
      sequence(:name) { |n| "ispick_twitter_d#{n}" }
      ignore do
        images_count 1
      end
      after(:create) do |user, evaluator|
        create_list(:delivered_image, evaluator.images_count, user: user)
        1.times { create(:delivered_image_photo, user: user) }
      end
    end

    factory :user_with_delivered_images_file do
      sequence(:name) { |n| "ispick_twitter_df#{n}" }
      ignore do
        images_count 1
      end
      after(:create) do |user, evaluator|
        create_list(:delivered_image_file, evaluator.images_count, user: user)
      end
    end

    factory :user_with_target_images do
      sequence(:name) { |n| "ispick_twitter_i#{n}" }
      ignore do
        images_count 5
      end
      after(:create) do |user, evaluator|
        create_list(:target_image, evaluator.images_count, user: user)
      end
    end

    factory :user_with_target_words do
      sequence(:name) { |n| "ispick_twitter_w#{n}" }
      ignore do
        words_count 5
      end
      after(:create) do |user, evaluator|
        #create_list(:target_words, evaluator.words_count, user: user)
        #create(:target_word_user, target_word: create(:target_words), user: user)
        create_list(:target_words_user, evaluator.words_count, target_word: create(:target_words), user: user)
      end
    end

    # デフォルトでユーザーが持つFavoredImage
    after(:create) do |user|
      # after_createで生成するので、それに追加する
      1.times { create(:favored_image_file, image_board: user.image_boards.first) }
    end

  end
  factory :facebook_user, class: User do
    email 'test@example.com'
    password '12345678'
    provider  'facebook'
    uid '12345678'
    sequence(:name) { |n| "ispick_facebook#{n}" }
  end

end
