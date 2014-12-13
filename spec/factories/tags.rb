# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :tag do
    #name '鹿目まどか'
    sequence(:name) { |n| "鹿目まどか#{n}" }

    # images(no file)を持つTagオブジェクト
    # A Tag object with images that have no files
    factory :tag_with_images do
      ignore do
        images_count 5
      end
      after(:create) do |tag, evaluator|
        evaluator.images_count.times do
          tag.images << create(:image)
        end
      end
    end

    # image(with file)を持つTag
    # A Tag object with images that have files
    factory :tag_with_image_file do
      ignore do
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


    # A Tag object which is associated with a Person record
    factory :tag_with_person do
      ignore do
        words_count 1
      end
      after(:build) do |tag, evaluator|
        create_list(:person_madoka, evaluator.words_count, tag: tag)
      end
      after(:build) { |tag| tag.class.skip_callback(:create, :after, :search_keyword) }
    end
  end




  factory :tag_en, class: Tag do
    name 'Madoka Kaname'
  end
  factory :tag_title, class: Tag do
    name '魔法少女まどか☆マギカ'
  end
  factory :tags, class: Tag do
    sequence(:name) { |n| "鹿目まどか#{n}" }

    after(:create) do |tag|
      5.times do
        tag.images << create(:image)
      end
    end
  end

  factory :tag_madoka, class: Tag do
    name 'Madoka Kaname'
  end
  factory :tag_sayaka, class: Tag do
    name 'Sayaka Miki'
  end
  factory :tag_single, class: Tag do
    name 'single'
  end
end
