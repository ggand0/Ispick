# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :authorization do
    provider 'twitter'
    uid '12345678'
    #token nil
    #secret ''
    after(:create) do |authorization|
      #authorization.credentials = OmniAuth::AuthHash.new({})
    end
  end
end
