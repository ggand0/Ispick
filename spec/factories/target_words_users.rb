# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :target_words_user, class: TargetWordsUser do
    target_word
    user
  end
end
