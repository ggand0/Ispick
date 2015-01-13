# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do

  factory :image_board_min, class: ImageBoard do
    name 'A board without images'
  end

  # This one generates boards used as a default board of a user
  factory :image_board do
    name 'Default'

    after(:create) do |image_board|
      1.times { create(:favored_image_file, image_board: image_board) }
    end
  end

  # Creates custom ImageBoard objects
  factory :image_boards, class: ImageBoard do
    sequence(:name) { |n| "My board#{n}" }

    after(:create) do |image_board|
      1.times { create(:favored_image_file, image_board: image_board) }
    end
  end
end
