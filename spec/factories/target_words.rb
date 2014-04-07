# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :target_word do
    word '鹿目 まどか（かなめ まどか）'

    factory :word_with_delivered_images do
      ignore do
        images_count 5
      end
      after(:create) do |target_word, evaluator|
        create_list(:delivered_image_with_targetable, evaluator.images_count, targetable: target_word)
      end
    end
  end
end
