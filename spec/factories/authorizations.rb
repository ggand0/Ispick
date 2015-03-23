# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :authorization, class: Authorization do
    provider 'twitter'
    uid '12345678'
  end

  factory :authorization_tumblr, class: Authorization do
    provider 'tumblr'
    uid '12345678'
  end
end
