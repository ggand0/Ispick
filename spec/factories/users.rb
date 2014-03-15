# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "test#{n}@example.com" }
    sequence(:password) { |n| "#{n}2345678" }
  end
  factory :twitter_user, class: User do
    email 'test@example.com'
    password '12345678'
    provider  'twitter'
    uid '12345678'
  end
  factory :facebook_user, class: User do
    email 'test@example.com'
    password '12345678'
    provider  'facebook'
    uid '12345678'
  end
end
