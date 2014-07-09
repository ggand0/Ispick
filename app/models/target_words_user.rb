class TargetWordsUser < ActiveRecord::Base
  belongs_to :target_word
  belongs_to :user
end
