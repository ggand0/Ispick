# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  # Defaultで生成されるBoard
  factory :image_board do
    name "Default"

    after(:create) do |image_board|
      1.times { create(:favored_image_file, image_board: image_board) }
    end
  end

  # Added by user
  factory :image_boards, class: ImageBoard do
    sequence(:name) { |n| "My board#{n}" }

    after(:create) do |image_board|
      1.times { create(:favored_image_file, image_board: image_board) }
    end
  end
end
