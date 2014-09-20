class Person < ActiveRecord::Base
  belongs_to :target_word

  has_many :people_keywords
  has_many :keywords, :through => :people_keywords

  has_many :people_titles
  has_many :titles, :through => :people_titles

  validates_uniqueness_of :name

  # Get name for displaying
  def get_name(language)
    if language == 'ja'
      name ? name : name_english
    else
      name_english
    end
  end
end
