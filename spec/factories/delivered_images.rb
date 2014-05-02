# Read about factories at https://github.com/thoughtbot/factory_girl
require "#{Rails.root}/spec/support/consts"

FactoryGirl.define do
  factory :delivered_image, class: DeliveredImage do
    avoided false
    association :user, factory: :twitter_user, strategy: :build
    association :targetable, factory: :target_word, strategy: :build
    association :image, factory: :image
  end

  factory :delivered_image_no_association, class: DeliveredImage do
    association :image, factory: :image
  end

  factory :delivered_image_with_targetable, class: DeliveredImage do
    avoided false
    association :targetable, factory: :target_word, strategy: :build
    association :image, factory: :image
  end

  factory :delivered_image_photo, class: DeliveredImage do
    association :image, factory: :image
    avoided false
  end
  factory :delivered_image_illust, class: DeliveredImage do
    association :image, factory: :image
    avoided false
  end

  factory :delivered_image_from_word, class: DeliveredImage do
    association :user, factory: :twitter_user, strategy: :build
    association :targetable, factory: :target_word
    association :image, factory: :image
  end

  factory :delivered_image_from_image, class: DeliveredImage do
    association :user, factory: :twitter_user, strategy: :build
    association :targetable, factory: :target_image
    association :image, factory: :image
  end

  factory :delivered_image_file, class: DeliveredImage do
    favored false

    # save時にvalidationをスキップする
    to_create do |instance|
      instance.save validate: false
    end

    association :user, factory: :twitter_user, strategy: :build
    association :targetable, factory: :target_word, strategy: :build
    association :image, factory: :image_file
  end

  factory :delivered_image_favored, class: DeliveredImage do
    favored true
    association :user
    association :image, factory: :image
  end
  #factory :delivered_image_favored_light, class: DeliveredImage do
  #  favored true
  #  association :image, factory: :image
  #end
  factory :delivered_image_unfavored_light, class: DeliveredImage do
    favored false
    association :image, factory: :image
  end
end
