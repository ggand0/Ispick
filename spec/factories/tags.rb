# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do

  # Creates a Tag that has sequenced name
  factory :tag do
    sequence(:name) { |n| "鹿目まどか#{n}" } # 'Madoka Kaname' in Japanese

    # Creates a Tag object which is associated with images that don't have actual image files(only attributes).
    # The default images_count is 5.
    factory :tag_with_images do
      transient do
        images_count 5
      end
      after(:create) do |tag, evaluator|
        evaluator.images_count.times do
          tag.images << create(:image)
        end
      end
    end

    # Creates a Tag object which is associated with images that have actual image files.
    # The default images_count is 1, since it takes time to save image files.
    factory :tag_with_image_file do
      transient do
        images_count 1
      end
      after(:create) do |tag, evaluator|
        evaluator.images_count.times do
          tag.images << create(:image_file)
        end
      end
    end

    factory :tag_with_image_dif_time do
      after(:create) do |tag|
        1.times do
          tag.images << create(:image_dif_time)
        end
      end
    end

    factory :tag_with_image_photo do
      after(:create) do |tag|
        1.times do
          tag.images << create(:image_photo)
        end
      end
    end

    # Creates a Tag object which is associated with a Person record
    factory :tag_with_person do
      transient do
        words_count 1
      end
      after(:build) do |tag, evaluator|
        create_list(:person_madoka, evaluator.words_count, tag: tag)
      end
      after(:build) { |tag| tag.class.skip_callback(:create, :after, :search_keyword) }
    end
  end



  # ======================================================
  #  Factories for creating tags that have specific names
  # ======================================================
  factory :tag_en, class: Tag do
    name 'Madoka Kaname'
  end
  factory :tag_title, class: Tag do
    name '魔法少女まどか☆マギカ'  # Puella Magi Madoka Magica
  end


  factory :tag_madoka, class: Tag do
    name 'Madoka Kaname'
  end
  factory :tag_madoka_roman, class: Tag do
    name 'Kaname Madoka'
  end
  factory :tag_sayaka, class: Tag do
    name 'Sayaka Miki'
  end
  factory :tag_sayaka_roman, class: Tag do
    name 'Miki Sayaka'
  end
  factory :tag_single, class: Tag do
    name 'single'
  end
end
