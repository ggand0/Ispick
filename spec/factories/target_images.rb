# Need to attach 'Rails.env.test?' or this crushes activeadmin pages.
# https://github.com/activeadmin/activeadmin/issues/512
include  ActionDispatch::TestProcess if Rails.env.test?

FactoryGirl.define do
  factory :target_image, class: TargetImage do
    data { fixture_file_upload('spec/fixtures/files/madoka0.jpg', 'image/jpg') }

    # Skip validation when saving
    to_create do |instance|
      instance.save validate: false
    end


    # =====================================
    #  TargetImage factories with features
    # =====================================
    factory :target_image_f1, class: TargetImage do
      after(:create) do |target_image|
        target_image.feature = create(:feature_test1)
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
    data { fixture_file_upload('spec/fixtures/files/madoka0.jpg', 'image/jpg') }
  end

  factory :target_image2, class: TargetImage do
    data { fixture_file_upload('spec/files/test_images/madoka1.jpg', 'image/jpg') }
  end

  factory :target_image_delivered, class: TargetImage do
    data { fixture_file_upload('spec/fixtures/files/madoka0.jpg', 'image/jpg') }
    last_delivered_at Time.utc(2014, 1, 1, 0,0,0)
  end
end