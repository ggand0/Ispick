# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :favored_image do
    title "MyText"
    caption "MyText"
    src_url "MyText"
    user_id 1
  end
end
