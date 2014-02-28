FactoryGirl.define do
  factory :feature_test1, class: Feature do
    face '[{"zero value": 0}]'
    association :featurable, factory: :target_image
  end
  # 顔特徴量を検出出来なかった画像
  factory :feature_test2, class: Feature do
    face '[]'
    association :featurable, factory: :target_image
  end

  factory :feature_madoka, class: Feature do
    face  '[{"likelihood":0.9999814629554749,"face":{"x":501,"y":286,"width":286,"height":286},"skin_color":{"blue":231,"green":244,"red":249},"hair_color":{"blue":170,"green":206,"red":249},"eyes":{"left":{"x":646,"y":349,"width":95,"height":62,"colors":{"blue":122,"green":135,"red":187}},"right":{"x":511,"y":399,"width":67,"height":56,"colors":{"blue":106,"green":130,"red":190}}},"nose":{"x":599,"y":463},"chin":{"x":653,"y":549}}]'
    association :featurable, factory: :target_image
  end

  # feature_madokaに似た特徴量を持つ画像を仮定（hair_colorのrgb+10してる）
  factory :feature_madoka1, class: Feature do
    face  '[{"likelihood":0.9999814629554749,"face":{"x":501,"y":286,"width":286,"height":286},"skin_color":{"blue":231,"green":244,"red":249},"hair_color":{"blue":180,"green":216,"red":259},"eyes":{"left":{"x":646,"y":349,"width":95,"height":62,"colors":{"blue":122,"green":135,"red":187}},"right":{"x":511,"y":399,"width":67,"height":56,"colors":{"blue":106,"green":130,"red":190}}},"nose":{"x":599,"y":463},"chin":{"x":653,"y":549}}]'
    association :featurable, factory: :image
  end

  # feature_madokaに似てない特徴量を持つ画像を仮定（hair_colorのgb+-50してる）
  factory :feature_madoka2, class: Feature do
    face  '[{"likelihood":0.9999814629554749,"face":{"x":501,"y":286,"width":286,"height":286},"skin_color":{"blue":231,"green":244,"red":249},"hair_color":{"blue":170,"green":255,"red":199},"eyes":{"left":{"x":646,"y":349,"width":95,"height":62,"colors":{"blue":122,"green":135,"red":187}},"right":{"x":511,"y":399,"width":67,"height":56,"colors":{"blue":106,"green":130,"red":190}}},"nose":{"x":599,"y":463},"chin":{"x":653,"y":549}}]'
    association :featurable, factory: :image
  end


  factory :feature_image, class: 'Feature' do
    sequence(:face) { |r| '[{"likelihood":0.9999814629554749,"face":{"x":501,"y":286,"width":286,"height":286},"skin_color":{"blue":231,"green":244,"red":249},"hair_color":{"blue":170,"green":206,"red":' + "#{(r * 10) % 256}" +'},"eyes":{"left":{"x":646,"y":349,"width":95,"height":62,"colors":{"blue":122,"green":135,"red":187}},"right":{"x":511,"y":399,"width":67,"height":56,"colors":{"blue":106,"green":130,"red":190}}},"nose":{"x":599,"y":463},"chin":{"x":653,"y":549}}]' }
    association :featurable, factory: :image
  end
end