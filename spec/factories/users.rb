# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  # A user which is created via an email address
  factory :user do
    sequence(:email) { |n| "test_user#{n}@example.com" }
    sequence(:password) { |n| "#{n}2345678" }
    sequence(:name) { |n| "ispick#{n}" }

    # デフォルトでユーザーが持つFavoredImageを作成
    # Create a default FavoredImage object of an user
    after(:create) do |user|
      1.times { create(:favored_image_file, image_board: user.image_boards.first) }
    end
  end

  # Creates user objects with model callbacks
  factory :user_with_callbacks, class: User do
    sequence(:email) { |n| "test#{n}@example.com" }
    password '12345678'
    provider  'twitter'
    uid '12345678'
    sequence(:name) { |n| "ispick_twitter#{n}" }
  end

  # A user which is created via a facebook account
  factory :facebook_user, class: User do
    email 'test@example.com'
    password '12345678'
    provider  'facebook'
    uid '12345678'
    sequence(:name) { |n| "ispick_facebook#{n}" }
  end

  # A user which is created via a twitter account
  factory :twitter_user, class: User do
    sequence(:email) { |n| "test#{n}@example.com" }
    password '12345678'
    provider  'twitter'
    uid '12345678'
    sequence(:name) { |n| "ispick_twitter#{n}" }

    # Create a FavoredImage record as default one
    after(:create) do |user|
      1.times { create(:favored_image_file, image_board: user.image_boards.first) }
    end

    # ==========================
    #  Users with target_images
    # ==========================
    factory :user_with_target_images do
      sequence(:name) { |n| "ispick_twitter_i#{n}" }
      ignore do
        images_count 5
      end
      after(:create) do |user, evaluator|
        create_list(:target_image, evaluator.images_count, user: user)
      end
    end


    # ==============================
    #  Users with target_words only
    # ==============================
    factory :user_with_target_words do
      sequence(:name) { |n| "ispick_twitter_w#{n}" }
      ignore do
        words_count 5
      end
      after(:create) do |user, evaluator|
        5.times do
          user.target_words << create(:target_words)
        end
      end
    end

    factory :user_with_target_word do
      sequence(:name) { |n| "ispick_twitter_w#{n}" }
      after(:create) do |user|
        1.times do
          user.target_words << create(:target_words)
        end
      end
    end


    # ==========================================
    #  Users with target_words that have images
    # ==========================================
    factory :user_with_target_word_images do
      sequence(:name) { |n| "ispick_twitter_w#{n}" }
      ignore do
        images_count 1
      end
      after(:create) do |user, evaluator|
        1.times do
          user.target_words << create(:word_with_images, images_count: evaluator.images_count)
        end
      end
    end

    factory :user_with_target_word_images_file do
      sequence(:name) { |n| "ispick_twitter_w#{n}" }
      ignore do
        images_count 1
      end
      after(:create) do |user, evaluator|
        1.times do
          user.target_words << create(:word_with_image_file, images_count: evaluator.images_count)
        end
      end
    end

    factory :user_with_target_word_dif_image do
      sequence(:name) { |n| "ispick_twitter_w#{n}" }
      after(:create) do |user|
        1.times do
          user.target_words << create(:word_with_images)
          user.target_words << create(:word_with_image_dif_time)
          #user.target_words << create(:word_with_image_photo)
        end
      end
    end

  end # factory :twitter_user
end
