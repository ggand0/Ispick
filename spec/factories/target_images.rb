include  ActionDispatch::TestProcess

FactoryGirl.define do
  factory :target_image, class: TargetImage do
    title 'madoka'
    data { fixture_file_upload('spec/fixtures/files/madoka.png', 'image/png') }

    factory :image_with_delivered_images do
      ignore do
        images_count 5
      end
      after(:create) do |target_image, evaluator|
        create_list(:delivered_image_with_targetable, evaluator.images_count, targetable: target_image)
      end
    end
  end

  factory :target_image1, class: TargetImage do
    title 'madoka1'
    data { fixture_file_upload('spec/fixtures/files/madoka.png', 'image/png') }
  end

  factory :target_image_delivered, class: TargetImage do
    title 'madoka'
    data { fixture_file_upload('spec/fixtures/files/madoka.png', 'image/png') }
    last_delivered_at Time.utc(2014, 1, 1, 0,0,0)
  end
end