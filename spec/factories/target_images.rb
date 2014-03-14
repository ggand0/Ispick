include  ActionDispatch::TestProcess

FactoryGirl.define do
  factory :target_image, class: TargetImage do
    title 'madoka'
    data { fixture_file_upload('spec/fixtures/files/madoka.png') }
  end

  factory :target_image1, class: TargetImage do
    title 'madoka1'
    data { fixture_file_upload('spec/fixtures/files/madoka.png') }
  end

  factory :target_image_delivered, class: TargetImage do
    title 'madoka'
    data { fixture_file_upload('spec/fixtures/files/madoka.png') }
    last_delivered_at Time.utc(2014, 1, 1, 0,0,0)
  end
end