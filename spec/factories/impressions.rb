# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :impression_user1, class: Impression do
    impressionable_type 'Image'
    sequence(:impressionable_id) { |n| n }
    #sequence(:user_id) { |n| n }
    user_id 1
    controller_name "images"
    action_name "show"
    ip_address "127.0.0.1"
    referrer "http://0.0.0.0:3000/images/search?query=VOCALOID"
    created_at DateTime.now.utc
    updated_at DateTime.now.utc
  end

  factory :impression_user2, class: Impression do
    impressionable_type 'Image'
    sequence(:impressionable_id) { |n| n }
    #sequence(:user_id) { |n| n }
    user_id 2
    controller_name "images"
    action_name "show"
    ip_address "127.0.0.1"
    referrer "http://0.0.0.0:3000/images/search?query=VOCALOID"
    created_at DateTime.now.utc
    updated_at DateTime.now.utc
  end

  factory :impression_user3, class: Impression do
    impressionable_type 'Image'
    sequence(:impressionable_id) { |n| n }
    user_id 3
    controller_name "images"
    action_name "show"
    ip_address "127.0.0.1"
    referrer "http://0.0.0.0:3000/images/search?query=VOCALOID"
    created_at DateTime.now.utc
    updated_at DateTime.now.utc
  end
end
