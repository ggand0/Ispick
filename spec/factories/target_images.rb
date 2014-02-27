include  ActionDispatch::TestProcess

FactoryGirl.define do
  factory :target_image, class: TargetImage do
    title 'madoka'
    data { fixture_file_upload('spec/fixtures/files/madoka.png') }
  end
end