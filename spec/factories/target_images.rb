include  ActionDispatch::TestProcess

FactoryGirl.define do
  factory :target_image, class: TargetImage do
    data { fixture_file_upload('spec/fixtures/files/madoka.png', 'image/png') }

    # save時にvalidationをスキップする
    to_create do |instance|
      instance.save validate: false
    end

    factory :image_with_delivered_images do
      ignore do
        images_count 5
      end
      after(:create) do |target_image, evaluator|
        create_list(:delivered_image_with_targetable, evaluator.images_count, targetable: target_image)
      end
    end
  end
  factory :target_image_nofile, class: TargetImage do
    enabled false
    to_create do |instance|
      instance.save validate: false
    end
  end
  factory :target_image_enabled, class: TargetImage do
    enabled true
    to_create do |instance|
      instance.save validate: false
    end
  end

  factory :target_image1, class: TargetImage do
    data { fixture_file_upload('spec/fixtures/files/madoka.png', 'image/png') }
  end

  factory :target_image2, class: TargetImage do
    data { fixture_file_upload('spec/files/test_images/madoka1.png', 'image/png') }
  end

  factory :target_image_delivered, class: TargetImage do
    data { fixture_file_upload('spec/fixtures/files/madoka.png', 'image/png') }
    last_delivered_at Time.utc(2014, 1, 1, 0,0,0)
  end
end